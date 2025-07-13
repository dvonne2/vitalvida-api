<?php
namespace App\Http\Controllers;
use App\Http\Requests\RegisterRequest;
use App\Http\Requests\LoginRequest;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    protected $maxAttempts = 5;
    protected $lockoutMinutes = 15;

    /**
     * 🚪 Portal roles mapping for your system
     */
    const PORTAL_ROLES = [
        'admin' => 'ceo',
        'superadmin' => 'ceo',
        'production' => 'manufacturing',
        'gm' => 'logistics',
        'fc' => 'finance',
        'im' => 'inventory',
        'da' => 'delivery_agent',
        'user' => 'delivery_agent',
        'finance' => 'finance',
        'inventory' => 'inventory',
        'logistics' => 'logistics',
        'delivery_agent' => 'delivery_agent',
        'telesales' => 'telesales',
        'marketing' => 'marketing',
        'kyc' => 'kyc',
        'accountant' => 'accountant',
        'manufacturing' => 'manufacturing',
        'hr' => 'hr'
    ];

    /**
     * Portal permissions mapping
     */
    const PORTAL_PERMISSIONS = [
        'ceo' => ['*'],
        'manufacturing' => ['manage_production', 'track_batches', 'quality_control'],
        'finance' => ['approve_payouts', 'view_financial', 'manage_compliance'],
        'inventory' => ['manage_inventory', 'view_bins', 'transfer_stock'],
        'logistics' => ['manage_agents', 'view_deliveries', 'track_sla'],
        'delivery_agent' => ['view_assignments', 'upload_proof', 'submit_otp'],
        'telesales' => ['manage_calls', 'view_leads', 'track_conversion'],
        'marketing' => ['view_campaigns', 'track_attribution', 'manage_media'],
        'kyc' => ['verify_documents', 'manage_onboarding', 'approve_kyc'],
        'accountant' => ['confirm_payments', 'reconcile_pos', 'view_financial'],
        'hr' => ['manage_staff', 'track_performance', 'handle_disciplinary']
    ];

    public function register(RegisterRequest $request)
    {
        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'role' => $request->role ?? 'user',
                'email_verified_at' => now(),
            ]);

            $token = $user->createToken('auth_token', ['*'], now()->addHours(24))->plainTextToken;

            // Get portal info for registration response
            $portalInfo = $this->getPortalInfo($user);

            return response()->json([
                'success' => true,
                'message' => 'User registered successfully',
                'access_token' => $token,
                'token_type' => 'Bearer',
                'expires_in' => 24 * 60 * 60,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role
                ],
                'portal' => $portalInfo
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Registration failed',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function login(LoginRequest $request)
    {
        $key = $this->throttleKey($request);
        
        // Check if user is locked out
        if ($this->hasTooManyLoginAttempts($request)) {
            $seconds = $this->availableIn($key);
            
            return response()->json([
                'success' => false,
                'message' => "Too many login attempts. Account locked for {$seconds} seconds.",
                'lockout_ends_at' => now()->addSeconds($seconds)->toISOString()
            ], 429);
        }

        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            $this->incrementLoginAttempts($request);
            
            $attempts = $this->attempts($key);
            $remaining = $this->maxAttempts - $attempts;
            
            throw ValidationException::withMessages([
                'email' => [
                    'The provided credentials are incorrect.',
                    $remaining > 0 ? "You have {$remaining} attempts remaining." : ''
                ],
            ]);
        }

        // Clear attempts on successful login
        $this->clearLoginAttempts($request);

        $token = $user->createToken('auth_token', ['*'], now()->addHours(24))->plainTextToken;

        // 🚪 NEW: Get portal information
        $portalInfo = $this->getPortalInfo($user);

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'access_token' => $token,
            'token_type' => 'Bearer',
            'expires_in' => 24 * 60 * 60,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role
            ],
            'portal' => $portalInfo  // 🚪 NEW: Portal information
        ]);
    }

    /**
     * 🚪 Get portal information for a user
     */
    private function getPortalInfo($user)
    {
        $role = $user->role ?? 'delivery_agent';
        $primaryPortal = self::PORTAL_ROLES[$role] ?? 'delivery_agent';
        $permissions = self::PORTAL_PERMISSIONS[$primaryPortal] ?? ['view_basic'];

        // Determine available portals based on role
        $availablePortals = [$primaryPortal];
        
        // Add additional portals for senior roles
        if (in_array($role, ['admin', 'superadmin'])) {
            $availablePortals = array_values(self::PORTAL_ROLES);
        } elseif ($role === 'gm') {
            $availablePortals = ['logistics', 'inventory', 'delivery_agent'];
        } elseif ($role === 'fc') {
            $availablePortals = ['finance', 'accountant'];
        }

        return [
            'primary_portal' => $primaryPortal,
            'available_portals' => array_unique($availablePortals),
            'permissions' => $permissions,
            'portal_name' => $this->getPortalName($primaryPortal),
            'portal_icon' => $this->getPortalIcon($primaryPortal)
        ];
    }

    /**
     * Get friendly portal name
     */
    private function getPortalName($portal)
    {
        $names = [
            'ceo' => 'CEO Portal',
            'manufacturing' => 'Manufacturing Portal',
            'finance' => 'Finance Portal',
            'inventory' => 'Inventory Portal',
            'logistics' => 'Logistics Portal',
            'delivery_agent' => 'Delivery Agent Portal',
            'telesales' => 'Telesales Portal',
            'marketing' => 'Marketing Portal',
            'kyc' => 'KYC Portal',
            'accountant' => 'Accountant Portal',
            'hr' => 'HR Portal'
        ];

        return $names[$portal] ?? 'General Portal';
    }

    /**
     * Get portal icon
     */
    private function getPortalIcon($portal)
    {
        $icons = [
            'ceo' => '👑',
            'manufacturing' => '🏭',
            'finance' => '💰',
            'inventory' => '📦',
            'logistics' => '🚚',
            'delivery_agent' => '🏃‍♂️',
            'telesales' => '☎️',
            'marketing' => '🎯',
            'kyc' => '🔍',
            'accountant' => '📊',
            'hr' => '👥'
        ];

        return $icons[$portal] ?? '🏢';
    }

    // Keep all your existing methods (throttle, forgot password, etc.)
    protected function throttleKey($request)
    {
        return strtolower($request->input('email')).'|'.$request->ip();
    }

    protected function hasTooManyLoginAttempts($request)
    {
        return Cache::has($this->throttleKey($request));
    }

    protected function incrementLoginAttempts($request)
    {
        $key = $this->throttleKey($request);
        $attempts = Cache::get($key, 0) + 1;
        
        if ($attempts >= $this->maxAttempts) {
            Cache::put($key, $attempts, now()->addMinutes($this->lockoutMinutes));
        } else {
            Cache::put($key, $attempts, now()->addMinutes(1));
        }
    }

    protected function clearLoginAttempts($request)
    {
        Cache::forget($this->throttleKey($request));
    }

    protected function attempts($key)
    {
        return Cache::get($key, 0);
    }

    protected function availableIn($key)
    {
        $lockoutTime = Cache::get($key.'_lockout', now());
        return max(0, $lockoutTime->diffInSeconds(now()));
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ]);
    }

    public function profile(Request $request)
    {
        $user = $request->user();
        $portalInfo = $this->getPortalInfo($user);

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role
            ],
            'portal' => $portalInfo
        ]);
    }
}
