<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class InventoryMovement extends Model
{
    protected $fillable = [
        'id', 'product_id', 'from_bin_id', 'to_bin_id', 'from_warehouse_id', 
        'to_warehouse_id', 'initiated_by', 'approved_by', 'quantity', 
        'movement_type', 'status', 'reason', 'condition_notes', 
        'approved_at', 'completed_at'
    ];

    protected $casts = [
        'approved_at' => 'datetime',
        'completed_at' => 'datetime',
        'quantity' => 'integer'
    ];

    public $incrementing = false;
    protected $keyType = 'string';

    // Relationships
    public function product(): BelongsTo { return $this->belongsTo(Product::class); }
    public function initiatedBy(): BelongsTo { return $this->belongsTo(User::class, 'initiated_by'); }
    public function approvedBy(): BelongsTo { return $this->belongsTo(User::class, 'approved_by'); }
    public function fromBin(): BelongsTo { return $this->belongsTo(BinStock::class, 'from_bin_id'); }
    public function toBin(): BelongsTo { return $this->belongsTo(BinStock::class, 'to_bin_id'); }

    // Scopes
    public function scopePending($query) { return $query->where('status', 'pending'); }
    public function scopeCompleted($query) { return $query->where('status', 'completed'); }

    // Business Logic
    public function canBeApproved(): bool { return $this->status === 'pending'; }
    public function canBeCompleted(): bool { return $this->status === 'approved'; }
}
