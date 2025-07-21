<?php

namespace App\Services;

use App\Models\Order;
use App\Models\OtpVerification;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Http;
use App\Services\SmsService;

class OtpService
{
    protected $smsService;

    public function __construct(SmsService $smsService)
    {
        $this->smsService = $smsService;
    }

    /**
     * Generate and send OTP to customer
     */
    public function generateAndSendOtp(Order $order): array
    {
        try {
            // Generate 6-digit OTP
            $otpCode = $this->generateSecureOtp();

            // Create OTP record
            $otpVerification = OtpVerification::create([
                'order_id' => $order->id,
                'delivery_agent_id' => $order->delivery_agent_id,
                'otp_code' => $otpCode,
                'otp_type' => 'delivery',
                'customer_phone' => $order->customer->phone,
                'status' => 'pending',
                'sent_at' => now(),
                'expires_at' => now()->addHours(24), // 24-hour expiry
                'attempts' => 0,
                'max_attempts' => 3
            ]);

            // Send OTP via SMS
            $smsResult = $this->sendOtpSms($order->customer->phone, $otpCode, $order->order_number);

            if ($smsResult['success']) {
                // Update OTP record with delivery status
                $otpVerification->update([
                    'sms_sent' => true,
                    'delivery_log' => json_encode($smsResult)
                ]);

                // Update Money Out Compliance
                $compliance = $order->moneyOutCompliance;
                if ($compliance) {
                    $compliance->update(['otp_submitted' => true]);
                }

                Log::info('OTP sent successfully', [
                    'order_id' => $order->order_number,
                    'customer_phone' => $order->customer->phone,
                    'otp_id' => $otpVerification->id,
                    'expires_at' => $otpVerification->expires_at
                ]);

                return [
                    'success' => true,
                    'message' => 'OTP sent to customer',
                    'otp_id' => $otpVerification->id,
                    'expires_at' => $otpVerification->expires_at,
                    'customer_phone' => $order->customer->phone
                ];
            } else {
                $otpVerification->update([
                    'status' => 'failed',
                    'delivery_log' => json_encode($smsResult)
                ]);

                return [
                    'success' => false,
                    'message' => 'Failed to send OTP',
                    'error' => $smsResult['error']
                ];
            }

        } catch (\Exception $e) {
            Log::error('OTP generation failed', [
                'order_id' => $order->order_number,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'message' => 'OTP generation failed',
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Verify OTP submitted by customer
     */
    public function verifyOtp(string $orderNumber, string $submittedOtp): array
    {
        $order = Order::where('order_number', $orderNumber)->first();

        if (!$order) {
            return ['success' => false, 'message' => 'Order not found'];
        }

        $otpVerification = $order->otpVerifications()
            ->where('status', 'pending')
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        if (!$otpVerification) {
            return [
                'success' => false, 
                'message' => 'No valid OTP found or OTP has expired'
            ];
        }

        // Increment attempt counter
        $otpVerification->increment('attempts');

        if ($otpVerification->otp_code === $submittedOtp) {
            // OTP is correct
            $otpVerification->update([
                'status' => 'verified',
                'verified_at' => now(),
                'verified_by' => auth()->id()
            ]);

            // Update order status
            $order->update(['status' => 'otp_verified']);

            // Update Money Out Compliance
            $compliance = $order->moneyOutCompliance;
            if ($compliance) {
                $compliance->update(['otp_submitted' => true]);
                $this->checkComplianceReadiness($compliance);
            }

            Log::info('OTP verified successfully', [
                'order_id' => $order->order_number,
                'otp_id' => $otpVerification->id,
                'customer_phone' => $order->customer->phone
            ]);

            return [
                'success' => true,
                'message' => 'OTP verified successfully',
                'order_ready_for_delivery' => true,
                'next_step' => 'Order ready for delivery - Friday photo verification pending'
            ];
        } else {
            // Wrong OTP - log attempt
            Log::warning('Invalid OTP submitted', [
                'order_id' => $order->order_number,
                'submitted_otp' => $submittedOtp,
                'attempts' => $otpVerification->attempts,
                'max_attempts' => $otpVerification->max_attempts
            ]);

            // Check if max attempts reached
            if ($otpVerification->attempts >= $otpVerification->max_attempts) {
                $otpVerification->update(['status' => 'failed']);
                
                return [
                    'success' => false,
                    'message' => 'Maximum OTP attempts exceeded. Please contact support.',
                    'max_attempts_reached' => true
                ];
            }

            return [
                'success' => false,
                'message' => 'Invalid OTP',
                'attempts_remaining' => $otpVerification->max_attempts - $otpVerification->attempts
            ];
        }
    }

    /**
     * Resend OTP to customer
     */
    public function resendOtp(string $orderNumber): array
    {
        $order = Order::where('order_number', $orderNumber)->first();

        if (!$order) {
            return ['success' => false, 'message' => 'Order not found'];
        }

        // Check if there's a recent OTP (within 5 minutes)
        $recentOtp = $order->otpVerifications()
            ->where('created_at', '>', now()->subMinutes(5))
            ->latest()
            ->first();

        if ($recentOtp) {
            return [
                'success' => false,
                'message' => 'Please wait 5 minutes before requesting another OTP',
                'wait_time' => 300 - now()->diffInSeconds($recentOtp->created_at)
            ];
        }

        // Generate new OTP
        return $this->generateAndSendOtp($order);
    }

    /**
     * Get OTP status for an order
     */
    public function getOtpStatus(string $orderNumber): array
    {
        $order = Order::where('order_number', $orderNumber)->first();

        if (!$order) {
            return ['success' => false, 'message' => 'Order not found'];
        }

        $otpVerification = $order->otpVerifications()
            ->latest()
            ->first();

        if (!$otpVerification) {
            return [
                'success' => true,
                'status' => 'no_otp',
                'message' => 'No OTP generated for this order'
            ];
        }

        return [
            'success' => true,
            'status' => $otpVerification->status,
            'otp_id' => $otpVerification->id,
            'sent_at' => $otpVerification->sent_at,
            'expires_at' => $otpVerification->expires_at,
            'verified_at' => $otpVerification->verified_at,
            'attempts' => $otpVerification->attempts,
            'max_attempts' => $otpVerification->max_attempts,
            'is_expired' => $otpVerification->expires_at < now(),
            'time_remaining' => $otpVerification->expires_at > now() ? 
                $otpVerification->expires_at->diffInMinutes(now()) : 0
        ];
    }

    /**
     * Generate cryptographically secure 6-digit OTP
     */
    private function generateSecureOtp(): string
    {
        return str_pad(random_int(100000, 999999), 6, '0', STR_PAD_LEFT);
    }

    /**
     * Send OTP via SMS service
     */
    private function sendOtpSms(string $phone, string $otp, string $orderNumber): array
    {
        try {
            $message = "Your VitalVida delivery OTP for order {$orderNumber} is: {$otp}. Valid for 24 hours. Do not share this code.";

            // Use SMS service to send message
            $response = $this->smsService->sendSms($phone, $message);

            return [
                'success' => true,
                'message_id' => $response['message_id'] ?? null,
                'provider_response' => $response
            ];

        } catch (\Exception $e) {
            Log::error('SMS sending failed', [
                'phone' => $phone,
                'order_number' => $orderNumber,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Check if Money Out Compliance is ready for payment
     */
    private function checkComplianceReadiness($compliance): void
    {
        if ($compliance->payment_verified &&
            $compliance->otp_submitted &&
            $compliance->friday_photo_approved) {
            
            $compliance->update([
                'three_way_match' => true,
                'compliance_status' => 'locked'
            ]);

            Log::info('Money Out Compliance ready for payment', [
                'order_id' => $compliance->order->order_number,
                'compliance_id' => $compliance->id,
                'amount' => $compliance->amount
            ]);
        }
    }
}
