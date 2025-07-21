<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'zoho_order_id',
        'customer_id',
        'customer_name',
        'customer_phone',
        'customer_email',
        'delivery_address',
        'items',
        'total_amount',
        'status',
        'payment_status',
        'payment_reference',
        'assigned_da_id',
        'assigned_at',
        'delivery_date',
        'delivery_otp',
        'otp_verified',
        'otp_verified_at',
        'delivery_notes'
    ];

    protected $casts = [
        'items' => 'array',
        'total_amount' => 'decimal:2',
        'otp_verified' => 'boolean',
        'assigned_at' => 'datetime',
        'delivery_date' => 'datetime',
        'otp_verified_at' => 'datetime'
    ];

    // Relationships
    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function deliveryAgent(): BelongsTo
    {
        return $this->belongsTo(User::class, 'assigned_da_id');
    }

    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    public function otpVerifications(): HasMany
    {
        return $this->hasMany(OtpVerification::class);
    }

    public function moneyOutCompliance(): HasOne
    {
        return $this->hasOne(MoneyOutCompliance::class);
    }

    public function paymentMismatches(): HasMany
    {
        return $this->hasMany(PaymentMismatch::class);
    }

    // Helper methods for your Moniepoint system
    public function isPaid()
    {
        return $this->payment_status === 'paid';
    }

    public function isDelivered()
    {
        return $this->status === 'delivered';
    }

    public function canBeDelivered()
    {
        return $this->isPaid() && $this->otp_verified;
    }

    public function getItemsCount()
    {
        return is_array($this->items) ? count($this->items) : 0;
    }

    public function getFormattedAmount()
    {
        return '₦' . number_format($this->total_amount, 2);
    }

    public function getStatusBadgeClass()
    {
        return match($this->status) {
            'pending' => 'bg-yellow-100 text-yellow-800',
            'confirmed' => 'bg-blue-100 text-blue-800',
            'processing' => 'bg-purple-100 text-purple-800',
            'ready_for_delivery' => 'bg-orange-100 text-orange-800',
            'assigned' => 'bg-indigo-100 text-indigo-800',
            'in_transit' => 'bg-cyan-100 text-cyan-800',
            'delivered' => 'bg-green-100 text-green-800',
            'cancelled' => 'bg-red-100 text-red-800',
            default => 'bg-gray-100 text-gray-800'
        };
    }
}
