<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DeliveryAgent extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id', 'da_code', 'vehicle_number', 'vehicle_type', 'status', 'current_location',
        'state', 'city', 'total_deliveries', 'successful_deliveries', 'returns_count',
        'complaints_count', 'rating', 'total_earnings', 'commission_rate', 'strikes_count',
        'working_hours', 'service_areas', 'delivery_zones', 'vehicle_status',
        'current_capacity_used', 'max_capacity', 'average_delivery_time', 'last_active_at'
    ];

    protected $casts = [
        'working_hours' => 'array',
        'service_areas' => 'array',
        'delivery_zones' => 'array',
        'performance_metrics' => 'array',
        'last_active_at' => 'datetime',
        'suspended_at' => 'datetime',
        'deleted_at' => 'datetime',
    ];

    public function user() 
    { 
        return $this->belongsTo(User::class); 
    }
    
    // Add zobin relationship if not present
    public function zobin() 
    { 
        return $this->hasOne(Bin::class, 'delivery_agent_id'); // Use Bin model as ZOBIN
    }
    
    public function recommendations() 
    { 
        return $this->hasMany(SystemRecommendation::class); 
    }
    
    public function photoAudits() 
    { 
        return $this->hasMany(PhotoAudit::class); 
    }
    
    // Calculate success rate
    public function getSuccessRateAttribute() 
    {
        return $this->total_deliveries > 0 
            ? round(($this->successful_deliveries / $this->total_deliveries) * 100, 2)
            : 0;
    }
    
    // Check if has minimum stock (3:3:3)
    public function hasMinimumStock() 
    {
        return $this->zobin && 
               $this->zobin->shampoo_count >= 3 && 
               $this->zobin->pomade_count >= 3 && 
               $this->zobin->conditioner_count >= 3;
    }

    // Scope for active DAs
    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }
}
