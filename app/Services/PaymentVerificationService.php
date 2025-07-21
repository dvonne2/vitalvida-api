<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use App\Models\PaymentMismatch;
use App\Models\Customer;
use App\Services\OtpService;
use App\Services\ZohoService;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;

class PaymentVerificationService
{
    protected $otpService;
    protected $zohoService;

    public function __construct(OtpService $otpService, ZohoService $zohoService)
    {
        $this->otpService = $otpService;
        $this->zohoService = $zohoService;
    }

    /**
     * Process payment verification with Order ID + Phone matching
     */
    public function processPayment(array $paymentData): array
    {
        DB::beginTransaction();

        try {
            // Find order by Order ID from webhook FIRST
            $order = Order::where('order_number', $paymentData['order_id'])->first();

            if (!$order) {
                // Create payment record for failed lookup
                $payment = $this->createPaymentRecord($paymentData);
                $result = $this->handleOrderNotFound($payment, $paymentData);
                DB::commit();
                return $result;
            }

            // Create payment record with order reference
            $payment = $this->createPaymentRecord($paymentData, $order);

            // Perform Order ID + Phone validation
            $matchResult = $this->validateOrderAndPhone($order, $paymentData);

            if ($matchResult['is_match']) {
                // Perfect match - proceed with OTP release
                $result = $this->processValidPayment($payment, $order, $paymentData);
            } else {
                // Mismatch detected - log for investigation
                $result = $this->processMismatchedPayment($payment, $order, $paymentData, $matchResult);
            }

            DB::commit();
            return $result;

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Payment verification failed', [
                'error' => $e->getMessage(),
                'payment_data' => $paymentData
            ]);

            return [
                'success' => false,
                'error' => 'Payment processing failed',
                'details' => $e->getMessage()
            ];
        }
    }

    /**
     * Validate Order ID + Phone combination (100% accuracy required)
     */
    private function validateOrderAndPhone(Order $order, array $paymentData): array
    {
        $customer = $order->customer;

        $orderIdMatch = $order->order_number === $paymentData['order_id'];
        $phoneMatch = $this->normalizePhone($customer->phone) ===
                     $this->normalizePhone($paymentData['customer_phone']);

        return [
            'is_match' => $orderIdMatch && $phoneMatch,
            'order_id_match' => $orderIdMatch,
            'phone_match' => $phoneMatch,
            'expected_phone' => $customer->phone,
            'received_phone' => $paymentData['customer_phone'],
            'expected_order_id' => $order->order_number,
            'received_order_id' => $paymentData['order_id']
        ];
    }

    /**
     * Process valid payment - trigger OTP and update systems
     */
    private function processValidPayment(Payment $payment, Order $order, array $paymentData): array
    {
        // Update payment status
        $payment->update([
            'customer_id' => $order->customer_id,
            'order_id' => $order->id,
            'status' => 'confirmed',
            'verified_at' => now(),
            'verified_by' => auth()->id()
        ]);

        // Update order status and payment status
        $order->update([
            'status' => 'confirmed',
            'payment_status' => 'paid',
            'payment_reference' => $payment->transaction_reference
        ]);

        // Update Money Out Compliance
        $compliance = $order->moneyOutCompliance;
        if ($compliance) {
            $compliance->update(['payment_verified' => true]);
        }

        // Generate and send OTP to customer
        $otpResult = $this->otpService->generateAndSendOtp($order);

        Log::info('Payment verified successfully', [
            'order_id' => $order->order_number,
            'payment_id' => $payment->id,
            'customer_phone' => $order->customer->phone,
            'amount' => $payment->amount,
            'otp_sent' => $otpResult['success']
        ]);

        return [
            'success' => true,
            'message' => 'Payment verified and OTP sent',
            'order_id' => $order->order_number,
            'payment_id' => $payment->id,
            'customer_phone' => $order->customer->phone,
            'otp_sent' => $otpResult['success'],
            'next_step' => 'Customer should receive OTP for delivery confirmation'
        ];
    }

    /**
     * Process mismatched payment - log for investigation
     */
    private function processMismatchedPayment(Payment $payment, Order $order, array $paymentData, array $matchResult): array
    {
        // Update payment as failed verification
        $payment->update([
            'customer_id' => $order->customer_id,
            'order_id' => $order->id,
            'status' => 'failed',
            'verified_at' => now(),
            'verified_by' => auth()->id()
        ]);

        // Create detailed mismatch record for investigation
        $mismatch = PaymentMismatch::create([
            'mismatch_id' => $this->generateMismatchId(),
            'order_id' => $order->id,
            'payment_id' => $payment->id,
            'entered_phone' => $paymentData['customer_phone'],
            'entered_order_id' => $paymentData['order_id'],
            'actual_phone' => $order->customer->phone,
            'actual_order_id' => $order->order_number,
            'mismatch_type' => $this->determineMismatchType($matchResult),
            'payment_amount' => $payment->amount,
            'webhook_payload' => $paymentData['raw_payload'] ?? json_encode($paymentData),
            'investigation_required' => true,
            'penalty_amount' => 10000.00 // ₦10,000 penalty
        ]);

        // Log mismatch for immediate attention
        Log::warning('Payment mismatch detected', [
            'mismatch_id' => $mismatch->mismatch_id,
            'order_id' => $order->order_number,
            'mismatch_type' => $mismatch->mismatch_type,
            'expected_phone' => $order->customer->phone,
            'received_phone' => $paymentData['customer_phone'],
            'expected_order_id' => $order->order_number,
            'received_order_id' => $paymentData['order_id'],
            'penalty_amount' => 10000.00
        ]);

        // Notify accountant immediately
        $this->notifyAccountantOfMismatch($mismatch);

        return [
            'success' => false,
            'message' => 'Payment mismatch detected - investigation required',
            'mismatch_id' => $mismatch->mismatch_id,
            'mismatch_type' => $mismatch->mismatch_type,
            'penalty_amount' => 10000.00,
            'details' => $matchResult,
            'next_step' => 'Accountant must investigate and correct the mismatch'
        ];
    }

    /**
     * Determine specific type of mismatch for targeted correction
     */
    private function determineMismatchType(array $matchResult): string
    {
        if (!$matchResult['order_id_match'] && !$matchResult['phone_match']) {
            return 'both';
        } elseif (!$matchResult['order_id_match']) {
            return 'order_id';
        } elseif (!$matchResult['phone_match']) {
            return 'phone';
        }
        return 'unknown';
    }

    /**
     * Normalize phone numbers for consistent comparison
     */
    private function normalizePhone(string $phone): string
    {
        // Remove all non-digits
        $cleaned = preg_replace('/\D/', '', $phone);

        // Handle Nigerian phone number formats
        if (strlen($cleaned) === 11 && substr($cleaned, 0, 1) === '0') {
            return substr($cleaned, 1); // Remove leading 0
        }

        if (strlen($cleaned) === 13 && substr($cleaned, 0, 3) === '234') {
            return substr($cleaned, 3); // Remove country code
        }

        return $cleaned;
    }

    /**
     * Create payment record from webhook data
     */
    private function createPaymentRecord(array $paymentData, Order $order = null): Payment
    {
        return Payment::create([
            'payment_id' => $this->generatePaymentId(),
            'amount' => $paymentData['amount'],
            'payment_method' => 'pos',
            'transaction_reference' => $paymentData['transaction_reference'],
            'moniepoint_reference' => $paymentData['transaction_reference'],
            'status' => 'pending',
            'paid_at' => $paymentData['payment_date'],
            'moniepoint_response' => $paymentData['raw_payload'] ?? json_encode($paymentData),
            'order_id' => $order?->id,
            'customer_id' => $order?->customer_id
        ]);
    }

    /**
     * Handle case where order is not found
     */
    private function handleOrderNotFound(Payment $payment, array $paymentData): array
    {
        $payment->update(['status' => 'failed']);

        Log::warning('Order not found for payment', [
            'order_id' => $paymentData['order_id'],
            'payment_id' => $payment->id,
            'amount' => $payment->amount
        ]);

        return [
            'success' => false,
            'message' => 'Order not found',
            'order_id' => $paymentData['order_id'],
            'payment_id' => $payment->id,
            'next_step' => 'Verify order exists in system'
        ];
    }

    /**
     * Generate unique mismatch ID
     */
    private function generateMismatchId(): string
    {
        $count = PaymentMismatch::count() + 1;
        return 'VV-MISMATCH-' . str_pad($count, 6, '0', STR_PAD_LEFT);
    }

    /**
     * Generate unique payment ID
     */
    private function generatePaymentId(): string
    {
        $count = Payment::count() + 1;
        return 'VV-PAY-' . str_pad($count, 6, '0', STR_PAD_LEFT);
    }

    /**
     * Notify accountant of payment mismatch
     */
    private function notifyAccountantOfMismatch(PaymentMismatch $mismatch): void
    {
        // This will be implemented with the notification system
        // For now, just log the notification
        Log::info('Mismatch notification queued', [
            'mismatch_id' => $mismatch->mismatch_id,
            'order_id' => $mismatch->order->order_number
        ]);
    }
}
