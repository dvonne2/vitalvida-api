<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\OtpLog;
use App\Models\ActionLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\Password;

class AuthController extends Controller
{
    /**
     * User login
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
            'device_name' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
                'error_code' => 'INVALID_CREDENTIALS'
            ], 401);
        }

        if (!$user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Account is deactivated',
                'error_code' => 'ACCOUNT_DEACTIVATED'
            ], 403);
        }

        // Update last login info
        $user->update([
            'last_login_at' => now(),
            'last_login_ip' => $request->ip(),
        ]);

        // Create token
        $token = $user->createToken($request->device_name ?? 'web')->plainTextToken;

        // Log the action
        ActionLog::create([
            'user_id' => $user->id,
            'action' => 'user.login',
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'metadata' => [
                'device_name' => $request->device_name,
                'login_method' => 'email'
            ]
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'role' => $user->role,
                    'kyc_status' => $user->kyc_status,
                    'is_active' => $user->is_active,
                ],
                'token' => $token,
                'token_type' => 'Bearer'
            ]
        ]);
    }

    /**
     * User registration
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|unique:users|regex:/^[0-9]{11}$/',
            'password' => ['required', 'confirmed', Password::defaults()],
            'role' => 'required|in:' . implode(',', array_keys(User::ROLES)),
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'password' => Hash::make($request->password),
            'role' => $request->role,
            'kyc_status' => 'pending',
        ]);

        // Log the action
        ActionLog::create([
            'user_id' => $user->id,
            'action' => 'user.register',
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'metadata' => [
                'role' => $request->role,
                'registration_method' => 'api'
            ]
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Registration successful. Please complete KYC verification.',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'role' => $user->role,
                    'kyc_status' => $user->kyc_status,
                ]
            ]
        ], 201);
    }

    /**
     * Get user profile
     */
    public function profile(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'role' => $user->role,
                    'kyc_status' => $user->kyc_status,
                    'is_active' => $user->is_active,
                    'email_verified_at' => $user->email_verified_at,
                    'phone_verified_at' => $user->phone_verified_at,
                    'last_login_at' => $user->last_login_at,
                    'created_at' => $user->created_at,
                ]
            ]
        ]);
    }

    /**
     * Update user profile
     */
    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|string|max:255',
            'phone' => 'sometimes|string|unique:users,phone,' . $user->id . '|regex:/^[0-9]{11}$/',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user->update($request->only(['name', 'phone']));

        // Log the action
        ActionLog::create([
            'user_id' => $user->id,
            'action' => 'user.profile_update',
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
            'metadata' => [
                'updated_fields' => array_keys($request->only(['name', 'phone']))
            ]
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated successfully',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'role' => $user->role,
                    'kyc_status' => $user->kyc_status,
                ]
            ]
        ]);
    }

    /**
     * User logout
     */
    public function logout(Request $request)
    {
        $user = $request->user();

        // Log the action
        ActionLog::create([
            'user_id' => $user->id,
            'action' => 'user.logout',
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        // Revoke all tokens for the user
        $user->tokens()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ]);
    }

    /**
     * Change password
     */
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'password' => ['required', 'confirmed', Password::defaults()],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Current password is incorrect',
                'error_code' => 'INVALID_CURRENT_PASSWORD'
            ], 400);
        }

        $user->update([
            'password' => Hash::make($request->password)
        ]);

        // Log the action
        ActionLog::create([
            'user_id' => $user->id,
            'action' => 'user.password_change',
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully'
        ]);
    }

    /**
     * Send OTP for phone verification
     */
    public function verifyPhone(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|string|regex:/^[0-9]{11}$/',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        // Generate OTP
        $otp = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        // Store OTP
        OtpLog::create([
            'otp_code' => $otp,
            'phone_number' => $request->phone,
            'type' => 'login',
            'status' => 'sent',
            'expires_at' => now()->addMinutes(10),
            'user_id' => $user->id,
            'ip_address' => $request->ip(),
            'user_agent' => $request->userAgent(),
        ]);

        // TODO: Integrate with SMS service to send OTP
        // For now, we'll return the OTP in response (remove in production)
        
        return response()->json([
            'success' => true,
            'message' => 'OTP sent successfully',
            'data' => [
                'phone' => $request->phone,
                'expires_in' => 600, // 10 minutes
                'otp' => $otp // Remove this in production
            ]
        ]);
    }

    /**
     * Verify OTP
     */
    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'phone' => 'required|string|regex:/^[0-9]{11}$/',
            'otp' => 'required|string|size:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $otpLog = OtpLog::where('phone_number', $request->phone)
            ->where('otp_code', $request->otp)
            ->where('type', 'login')
            ->where('status', 'sent')
            ->where('expires_at', '>', now())
            ->first();

        if (!$otpLog) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid or expired OTP',
                'error_code' => 'INVALID_OTP'
            ], 400);
        }

        // Mark OTP as verified
        $otpLog->update([
            'status' => 'verified',
            'verified_at' => now(),
        ]);

        // Update user phone verification
        $user = User::find($otpLog->user_id);
        $user->update([
            'phone_verified_at' => now(),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Phone number verified successfully'
        ]);
    }

    /**
     * Forgot password
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::where('email', $request->email)->first();

        // Generate reset token
        $token = Str::random(60);
        
        // Store reset token (you might want to create a password_resets table)
        // For now, we'll use a simple approach

        // TODO: Send reset email
        // For now, we'll return success

        return response()->json([
            'success' => true,
            'message' => 'Password reset link sent to your email'
        ]);
    }

    /**
     * Reset password
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
            'email' => 'required|email|exists:users,email',
            'password' => ['required', 'confirmed', Password::defaults()],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        // TODO: Verify token and reset password
        // For now, we'll return success

        return response()->json([
            'success' => true,
            'message' => 'Password reset successfully'
        ]);
    }
} 