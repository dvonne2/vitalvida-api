<?php

namespace App\Http\Controllers;

use App\Http\Requests\DeductInventoryRequest;
use App\Services\InventoryService;
use App\Services\PaymentVerificationService;
use App\Services\OtpVerificationService;
use App\Models\InventoryAudit;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InventoryController extends Controller
{
    private $inventoryService;
    private $paymentService;
    private $otpService;

    public function __construct(
        InventoryService $inventoryService,
        PaymentVerificationService $paymentService,
        OtpVerificationService $otpService
    ) {
        $this->inventoryService = $inventoryService;
        $this->paymentService = $paymentService;
        $this->otpService = $otpService;
    }

    public function deductInventory(DeductInventoryRequest $request): JsonResponse
    {
        try {
            $result = $this->inventoryService->deductInventory($request->validated());

            return response()->json([
                'success' => true,
                'message' => 'Inventory deducted successfully after payment and OTP verification',
                'data' => $result
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    public function checkDeductionEligibility(Request $request): JsonResponse
    {
        $orderNumber = $request->get('order_number');
        
        if (!$orderNumber) {
            return response()->json([
                'success' => false,
                'message' => 'Order number is required'
            ], 400);
        }

        $paymentStatus = $this->paymentService->verifyPaymentStatus($orderNumber);
        $otpRequired = $this->otpService->isOtpRequired($orderNumber);
        
        return response()->json([
            'success' => true,
            'order_number' => $orderNumber,
            'payment_verified' => $paymentStatus['verified'],
            'payment_message' => $paymentStatus['message'],
            'otp_required' => $otpRequired,
            'ready_for_deduction' => $paymentStatus['verified'] && !$otpRequired
        ]);
    }

    public function getAuditTrail(string $orderNumber): JsonResponse
    {
        $audits = InventoryAudit::where('order_number', $orderNumber)
            ->with('user')
            ->orderBy('deducted_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'audits' => $audits
        ]);
    }
}
