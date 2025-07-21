<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PerformanceMetric extends Model
{
    protected $fillable = [
        'employee_id',
        'month',
        'individual_score',
        'team_score',
        'individual_targets_met',
        'team_targets_met',
        'quality_score',
        'attendance_score',
        'customer_satisfaction',
        'innovation_points',
        'overall_rating'
    ];

    protected $casts = [
        'month' => 'date',
        'individual_score' => 'decimal:2',
        'team_score' => 'decimal:2',
        'quality_score' => 'decimal:2',
        'attendance_score' => 'decimal:2',
        'customer_satisfaction' => 'decimal:2',
        'innovation_points' => 'integer',
        'overall_rating' => 'decimal:2'
    ];

    public function employee(): BelongsTo
    {
        return $this->belongsTo(User::class, 'employee_id');
    }
} 