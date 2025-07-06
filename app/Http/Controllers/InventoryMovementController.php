<?php

namespace App\Http\Controllers;

use App\Models\InventoryMovement;
use App\Models\ApprovalLog;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class InventoryMovementController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = InventoryMovement::query();
        
        if ($request->has('status')) {
            $query->where('approval_status', $request->status);
        }
        
        $movements = $query->orderBy('created_at', 'desc')->paginate(15);
        
        return response()->json([
            'success' => true,
            'data' => $movements,
            'message' => 'Inventory movements retrieved successfully'
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => 'required|integer',
            'movement_type' => 'required|string',
            'quantity' => 'required|numeric|min:0.01',
            'unit_cost' => 'nullable|numeric|min:0',
            'total_cost' => 'nullable|numeric|min:0',
            'reason' => 'nullable|string',
            'notes' => 'nullable|string',
        ]);

        // Calculate total cost if not provided
        if (!isset($validated['total_cost']) && isset($validated['unit_cost'])) {
            $validated['total_cost'] = $validated['quantity'] * $validated['unit_cost'];
        }

        // Set approval status based on threshold
        $threshold = 1000.00;
        $requiresApproval = ($validated['total_cost'] ?? 0) > $threshold;
        
        $validated['approval_status'] = $requiresApproval ? 'pending' : 'approved';
        $validated['user_id'] = 1;
        $validated['status'] = 'pending';
        
        if (!$requiresApproval) {
            $validated['approved_by'] = 1;
            $validated['approved_at'] = now();
        }

        $movement = InventoryMovement::create($validated);
        
        return response()->json([
            'success' => true,
            'data' => $movement,
            'message' => $requiresApproval ? 'Movement created and pending approval' : 'Movement created and auto-approved'
        ], 201);
    }

    public function show($id): JsonResponse
    {
        $movement = InventoryMovement::findOrFail($id);
        
        return response()->json([
            'success' => true,
            'data' => $movement,
            'message' => 'Movement retrieved successfully'
        ]);
    }

    public function approve(Request $request, $id): JsonResponse
    {
        $movement = InventoryMovement::findOrFail($id);
        
        if ($movement->approval_status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Movement is not pending approval'
            ], 400);
        }
        
        $validated = $request->validate([
            'notes' => 'nullable|string|max:1000'
        ]);
        
        $movement->update([
            'approval_status' => 'approved',
            'approved_by' => 1,
            'approved_at' => now(),
            'approval_notes' => $validated['notes'] ?? null
        ]);
        
        return response()->json([
            'success' => true,
            'data' => $movement,
            'message' => 'Movement approved successfully'
        ]);
    }

    public function reject(Request $request, $id): JsonResponse
    {
        $movement = InventoryMovement::findOrFail($id);
        
        if ($movement->approval_status !== 'pending') {
            return response()->json([
                'success' => false,
                'message' => 'Movement is not pending approval'
            ], 400);
        }
        
        $validated = $request->validate([
            'notes' => 'required|string|max:1000'
        ]);
        
        $movement->update([
            'approval_status' => 'rejected',
            'approved_by' => 1,
            'approved_at' => now(),
            'approval_notes' => $validated['notes']
        ]);
        
        return response()->json([
            'success' => true,
            'data' => $movement,
            'message' => 'Movement rejected successfully'
        ]);
    }

    public function getPendingApproval(): JsonResponse
    {
        $movements = InventoryMovement::where('approval_status', 'pending')
            ->orderBy('created_at', 'desc')
            ->get();
        
        return response()->json([
            'success' => true,
            'data' => $movements,
            'message' => 'Pending movements retrieved successfully'
        ]);
    }

    public function approvalLogs($id): JsonResponse
    {
        $movement = InventoryMovement::findOrFail($id);
        
        return response()->json([
            'success' => true,
            'data' => [],
            'message' => 'Approval logs retrieved successfully'
        ]);
    }
}
