<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class EscalationRequest extends Model
{
    protected $fillable = [
        'threshold_violation_id',
        'escalation_type',
        'amount_requested',
        'threshold_limit',
        'overage_amount',
        'approval_required',
        'escalation_reason',
        'business_justification',
        'status',
        'priority',
        'expires_at',
        'created_by',
        'final_decision_at',
        'final_outcome',
        'rejection_reason'
    ];

    protected $casts = [
        'amount_requested' => 'decimal:2',
        'threshold_limit' => 'decimal:2',
        'overage_amount' => 'decimal:2',
        'approval_required' => 'array',
        'expires_at' => 'datetime',
        'final_decision_at' => 'datetime'
    ];

    public function thresholdViolation(): BelongsTo
    {
        return $this->belongsTo(ThresholdViolation::class);
    }

    public function approvalDecisions(): HasMany
    {
        return $this->hasMany(ApprovalDecision::class);
    }

    /**
     * Get the user who created this escalation
     */
    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    /**
     * Check if escalation is pending approval
     */
    public function isPending(): bool
    {
        return $this->status === 'pending_approval' && $this->expires_at > now();
    }

    /**
     * Check if escalation has expired
     */
    public function isExpired(): bool
    {
        return $this->expires_at < now() && $this->status === 'pending_approval';
    }

    /**
     * Get time remaining before expiration
     */
    public function getTimeRemaining(): string
    {
        if ($this->isExpired()) {
            return 'Expired';
        }
        
        return $this->expires_at->diffForHumans();
    }

    /**
     * Get pending approvers for this escalation
     */
    public function getPendingApprovers(): array
    {
        $requiredApprovers = $this->approval_required;
        $decidedApprovers = $this->approvalDecisions->pluck('approver_role')->toArray();
        
        return array_diff($requiredApprovers, $decidedApprovers);
    }
} 