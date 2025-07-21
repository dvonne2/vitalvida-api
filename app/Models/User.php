<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Validation\Rule;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role',
        'is_active',
        'kyc_status',
        'avatar',
        'last_login_at',
        'fcm_token',
        'date_of_birth',
        'gender',
        'address',
        'city',
        'state',
        'country',
        'postal_code',
        'emergency_contact',
        'emergency_phone',
        'bio',
        'preferences',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_login_at' => 'datetime',
        'date_of_birth' => 'date',
        'is_active' => 'boolean',
        'preferences' => 'array',
    ];

    // Profile validation rules
    public static function getValidationRules($isUpdate = false, $userId = null)
    {
        $emailRule = $isUpdate 
            ? ['required', 'email', 'max:255', Rule::unique('users')->ignore($userId)]
            : ['required', 'email', 'max:255', 'unique:users'];

        $phoneRule = $isUpdate
            ? ['nullable', 'string', 'max:20', 'regex:/^[\+]?[0-9\-\(\)\s]+$/', Rule::unique('users')->ignore($userId)]
            : ['nullable', 'string', 'max:20', 'regex:/^[\+]?[0-9\-\(\)\s]+$/', 'unique:users'];

        return [
            'name' => ['required', 'string', 'max:255', 'min:2'],
            'email' => $emailRule,
            'phone' => $phoneRule,
            'date_of_birth' => ['nullable', 'date', 'before:today', 'after:1900-01-01'],
            'gender' => ['nullable', 'in:male,female,other,prefer_not_to_say'],
            'address' => ['nullable', 'string', 'max:500'],
            'city' => ['nullable', 'string', 'max:100'],
            'state' => ['nullable', 'string', 'max:100'],
            'country' => ['nullable', 'string', 'max:100'],
            'postal_code' => ['nullable', 'string', 'max:20'],
            'emergency_contact' => ['nullable', 'string', 'max:255'],
            'emergency_phone' => ['nullable', 'string', 'max:20', 'regex:/^[\+]?[0-9\-\(\)\s]+$/'],
            'bio' => ['nullable', 'string', 'max:1000'],
            'preferences' => ['nullable', 'array'],
        ];
    }

    // Password validation rules
    public static function getPasswordRules($isUpdate = false)
    {
        return $isUpdate 
            ? ['nullable', 'string', 'min:8', 'confirmed', 'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/']
            : ['required', 'string', 'min:8', 'confirmed', 'regex:/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$/'];
    }

    // Profile completion percentage
    public function getProfileCompletionAttribute(): int
    {
        $fields = ['name', 'email', 'phone', 'date_of_birth', 'gender', 'address', 'city', 'bio'];
        $completed = 0;
        
        foreach ($fields as $field) {
            if (!empty($this->$field)) {
                $completed++;
            }
        }
        
        return round(($completed / count($fields)) * 100);
    }

    // Check if user is delivery agent
    public function isDeliveryAgent(): bool
    {
        return $this->deliveryAgent()->exists();
    }

    // Get delivery agent profile
    public function deliveryAgent(): HasOne
    {
        return $this->hasOne(DeliveryAgent::class);
    }

    // Scope for delivery agents
    public function scopeDeliveryAgents($query)
    {
        return $query->whereHas('deliveryAgent');
    }

    // Update last login
    public function updateLastLogin(): void
    {
        $this->update(['last_login_at' => now()]);
    }

    // Scope for active users
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    // Get user's age
    public function getAgeAttribute(): ?int
    {
        return $this->date_of_birth ? $this->date_of_birth->age : null;
    }

    // Get full address
    public function getFullAddressAttribute(): string
    {
        $parts = array_filter([
            $this->address,
            $this->city,
            $this->state,
            $this->postal_code,
            $this->country
        ]);
        
        return implode(', ', $parts);
    }

    /**
     * Get the user's threshold violations
     */
    public function thresholdViolations()
    {
        return $this->hasMany(ThresholdViolation::class, 'created_by');
    }

    /**
     * Get the user's salary deductions
     */
    public function salaryDeductions()
    {
        return $this->hasMany(SalaryDeduction::class, 'user_id');
    }

    /**
     * Get the user's bonuses
     */
    public function bonuses()
    {
        return $this->hasMany(Bonus::class, 'employee_id');
    }

    /**
     * Get the user's payslips
     */
    public function payslips()
    {
        return $this->hasMany(Payslip::class, 'employee_id');
    }

    /**
     * Get the user's performance metrics
     */
    public function performanceMetrics()
    {
        return $this->hasMany(PerformanceMetric::class, 'employee_id');
    }

    /**
     * Get the user's logistics metrics
     */
    public function logisticsMetrics()
    {
        return $this->hasMany(LogisticsMetric::class, 'employee_id');
    }

    /**
     * Get the user's special bonus requests
     */
    public function specialBonusRequests()
    {
        return $this->hasMany(SpecialBonusRequest::class, 'employee_id');
    }
}
