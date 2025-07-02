<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\InventoryMovement;
use Illuminate\Http\Request;

class InventoryMovementController extends Controller
{
    public function index()
    {
        return response()->json(['status' => 'index works', 'time' => now()]);
    }

    public function storeDaToDA(Request $request)
    {
        try {
            $movement = InventoryMovement::create([
                'product_id' => $request->input('product_id', 1),
                'from_bin_id' => $request->input('from_bin_id', 1),
                'to_bin_id' => $request->input('to_bin_id', 2),
                'quantity' => $request->input('quantity', 1),
                'movement_type' => 'da_to_da',
                'reason' => $request->input('reason', 'test'),
                'status' => 'pending'
            ]);

            return response()->json([
                'success' => true,
                'data' => $movement,
                'message' => 'Movement created successfully!'
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function stats()
    {
        return response()->json([
            'total_movements' => InventoryMovement::count(),
            'status' => 'stats working'
        ]);
    }
}
