<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role',
        'kyc_status',
        'kyc_data',
        'zoho_user_id',
        'is_active',
        'email_verified_at',
        'phone_verified_at',
        'last_login_at',
        'last_login_ip',
    ];

    protected $hidden = [
        'password',
        'remember_token',
        'kyc_data',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'phone_verified_at' => 'datetime',
            'last_login_at' => 'datetime',
            'password' => 'hashed',
            'kyc_data' => 'array',
            'is_active' => 'boolean',
        ];
    }

    public const ROLES = [
        'production' => 'Production Manager',
        'inventory' => 'Inventory Manager',
        'telesales' => 'Telesales Agent',
        'DA' => 'Delivery Agent',
        'accountant' => 'Accountant',
        'CFO' => 'Chief Financial Officer',
        'CEO' => 'Chief Executive Officer',
        'superadmin' => 'Super Administrator'
    ];

    public function hasRole($role): bool
    {
        return $this->role === $role;
    }

    public function hasAnyRole($roles): bool
    {
        if (is_string($roles)) {
            return $this->role === $roles;
        }

        return in_array($this->role, $roles);
    }

    /**
     * Enhanced role constants matching your RBAC navigation
     */
    public const RBAC_ROLES = [
        'superadmin' => 'Super Administrator',
        'production' => 'Production Manager',
        'inventory' => 'Inventory Manager',
        'telesales' => 'Telesales Agent',
        'delivery' => 'Delivery Agent',
        'accountant' => 'Accountant',
        'cfo' => 'Chief Financial Officer',
        'ceo' => 'Chief Executive Officer',
        'hr' => 'Human Resources',
        'manufacturing' => 'Manufacturing',
        'media_buyer' => 'Media Buyer',
        'investor' => 'Investor'
    ];

    public function isSuperAdmin(): bool
    {
        return $this->role === 'superadmin';
    }

    public function getAccessibleNavigation(): array
    {
        if ($this->isSuperAdmin()) {
            return [
                'dashboard' => true,
                'user_management' => true,
                'system_logs' => true,
                'settings' => true,
                'database' => true,
                'production' => true,
                'inventory' => true,
                'telesales' => true,
                'delivery' => true,
                'accounting' => true,
                'finance' => true,
                'executive' => true,
                'hr' => true,
                'manufacturing' => true,
                'media_buying' => true,
                'investor_portal' => true,
            ];
        }

        $navigation = ['dashboard' => true];

        switch ($this->role) {
            case 'production':
                $navigation['production'] = true;
                break;
            case 'inventory':
                $navigation['inventory'] = true;
                break;
            case 'telesales':
                $navigation['telesales'] = true;
                break;
            case 'delivery':
                $navigation['delivery'] = true;
                break;
            case 'accountant':
                $navigation['accounting'] = true;
                break;
            case 'cfo':
                $navigation['finance'] = true;
                $navigation['accounting'] = true;
                break;
            case 'ceo':
                $navigation['executive'] = true;
                $navigation['finance'] = true;
                break;
            case 'hr':
                $navigation['hr'] = true;
                $navigation['user_management'] = true;
                break;
        }

        return $navigation;
    }

    public function isDeliveryAgent(): bool
    {
        return $this->role === 'DA';
    }

    public function isManager(): bool
    {
        return in_array($this->role, ['CFO', 'CEO', 'superadmin']);
    }

    // Relationships

    public function purchaseOrders()
    {
        return $this->hasMany(PurchaseOrder::class, 'created_by');
    }

    public function approvedPurchaseOrders()
    {
        return $this->hasMany(PurchaseOrder::class, 'approved_by');
    }

    public function qcCheckedPurchaseOrders()
    {
        return $this->hasMany(PurchaseOrder::class, 'qc_checked_by');
    }

    public function handoverPurchaseOrders()
    {
        return $this->hasMany(PurchaseOrder::class, 'handover_to');
    }

    public function inventoryLogs()
    {
        return $this->hasMany(InventoryLog::class);
    }

    public function assignedOrders()
    {
        return $this->hasMany(Order::class, 'assigned_da_id');
    }

    public function customerOrders()
    {
        return $this->hasMany(Order::class, 'customer_id');
    }

    public function paymentLogs()
    {
        return $this->hasMany(PaymentLog::class);
    }

    public function assignedLeads()
    {
        return $this->hasMany(Lead::class, 'assigned_to');
    }

    public function deliveryAgent()
    {
        return $this->hasOne(DeliveryAgent::class);
    }

    public function bonusLogs()
    {
        return $this->hasMany(BonusLog::class);
    }

    public function approvedBonusLogs()
    {
        return $this->hasMany(BonusLog::class, 'approved_by');
    }

    public function kycLogs()
    {
        return $this->hasMany(KycLog::class);
    }

    public function verifiedKycLogs()
    {
        return $this->hasMany(KycLog::class, 'verified_by');
    }

    public function actionLogs()
    {
        return $this->hasMany(ActionLog::class);
    }

    public function otpLogs()
    {
        return $this->hasMany(OtpLog::class);
    }

    public function pressoneLogs()
    {
        return $this->hasMany(PressoneLog::class);
    }

    public function matchedUnmatchedPayments()
    {
        return $this->hasMany(UnmatchedPayment::class, 'matched_by');
    }

    // Scopes

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeByRole($query, $role)
    {
        return $query->where('role', $role);
    }

    public function scopeByKycStatus($query, $status)
    {
        return $query->where('kyc_status', $status);
    }
}
