<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AgentPerformanceController;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

// Enhanced Test routes for agent performance
Route::prefix('test')->group(function () {
    Route::get('/agents/search', [AgentPerformanceController::class, 'searchAgents']);
    Route::get('/agents/available', [AgentPerformanceController::class, 'getAvailableAgents']);
    Route::get('/agents/load-status', [AgentPerformanceController::class, 'getAgentLoadStatus']);
    
    // NEW: Priority 1 Features
    Route::get('/agents/rankings', [AgentPerformanceController::class, 'getAgentRankings']);
    Route::get('/agents/reports', [AgentPerformanceController::class, 'getAgentReports']);
    Route::get('/agents/reports/{agent_id}', [AgentPerformanceController::class, 'getAgentReports']);
    
    // FIXED: Use existing method instead of getAnalytics
    Route::get('/agents/analytics', [AgentPerformanceController::class, 'getAgentRankings']);
});

// Enhanced Authentication Routes - Hour 4
Route::prefix('auth')->group(function () {
    // Public routes with rate limiting
    Route::middleware('throttle:5,1')->group(function () {
        Route::post('/login', [App\Http\Controllers\AuthController::class, 'login']);
        Route::post('/forgot-password', [App\Http\Controllers\AuthController::class, 'forgotPassword']);
        Route::post('/reset-password', [App\Http\Controllers\AuthController::class, 'resetPassword']);
    });
    
    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {
        Route::get('/profile', [App\Http\Controllers\AuthController::class, 'profile']);
        Route::post('/logout', [App\Http\Controllers\AuthController::class, 'logout']);
        Route::post('/logout-all', [App\Http\Controllers\AuthController::class, 'logoutAll']);
        Route::post('/change-password', [App\Http\Controllers\AuthController::class, 'changePassword']);
    });
});

// Test routes for development
Route::prefix('test/auth')->middleware('throttle:10,1')->group(function () {
    Route::post('/login', [App\Http\Controllers\AuthController::class, 'login']);
    Route::post('/forgot-password', [App\Http\Controllers\AuthController::class, 'forgotPassword']);
    Route::post('/reset-password', [App\Http\Controllers\AuthController::class, 'resetPassword']);
});

// Profile Management Routes - Hour 5
Route::middleware('auth:sanctum')->prefix('profile')->group(function () {
    Route::get('/', [App\Http\Controllers\Api\ProfileController::class, 'show']);
    Route::put('/', [App\Http\Controllers\Api\ProfileController::class, 'update']);
    Route::put('/preferences', [App\Http\Controllers\Api\ProfileController::class, 'updatePreferences']);
    Route::put('/password', [App\Http\Controllers\Api\ProfileController::class, 'changePassword']);
    Route::delete('/account', [App\Http\Controllers\Api\ProfileController::class, 'deleteAccount']);
});

// Test routes for development
Route::middleware('auth:sanctum')->prefix('test/profile')->group(function () {
    Route::get('/', [App\Http\Controllers\Api\ProfileController::class, 'show']);
    Route::put('/', [App\Http\Controllers\Api\ProfileController::class, 'update']);
    Route::put('/preferences', [App\Http\Controllers\Api\ProfileController::class, 'updatePreferences']);
});

// 🚪 PORTAL ROUTES - Hour 6 Implementation
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    // Manufacturing Portal (for production role users)
    Route::prefix('manufacturing')->group(function () {
        Route::get('/dashboard', function(Request $request) {
            $user = $request->user();
            return response()->json([
                'success' => true,
                'portal' => 'manufacturing',
                'user' => $user->name,
                'message' => 'Welcome to Manufacturing Portal',
                'data' => [
                    'active_batches' => 12,
                    'completed_today' => 8,
                    'quality_pending' => 3,
                    'production_efficiency' => '94%'
                ]
            ]);
        });
        
        Route::get('/batches', function(Request $request) {
            return response()->json([
                'success' => true,
                'data' => [
                    ['batch_id' => 'B001', 'product' => 'VitaMax', 'status' => 'in_production', 'progress' => '65%'],
                    ['batch_id' => 'B002', 'product' => 'HealthPlus', 'status' => 'quality_check', 'progress' => '90%'],
                    ['batch_id' => 'B003', 'product' => 'WellnessPro', 'status' => 'completed', 'progress' => '100%']
                ]
            ]);
        });
    });
    
    // Finance Portal
    Route::prefix('finance')->group(function () {
        Route::get('/dashboard', function(Request $request) {
            return response()->json([
                'success' => true,
                'portal' => 'finance',
                'user' => $request->user()->name,
                'message' => 'Welcome to Finance Portal',
                'data' => [
                    'pending_payouts' => 25,
                    'total_amount_pending' => 45000,
                    'approved_today' => 18,
                    'compliance_score' => '98%'
                ]
            ]);
        });
    });
    
    // Inventory Portal
    Route::prefix('inventory')->group(function () {
        Route::get('/dashboard', function(Request $request) {
            return response()->json([
                'success' => true,
                'portal' => 'inventory',
                'user' => $request->user()->name,
                'message' => 'Welcome to Inventory Portal',
                'data' => [
                    'total_bins' => 70,
                    'low_stock_alerts' => 5,
                    'pending_transfers' => 12,
                    'stock_accuracy' => '96%'
                ]
            ]);
        });
    });
    
    // Logistics Portal
    Route::prefix('logistics')->group(function () {
        Route::get('/dashboard', function(Request $request) {
            return response()->json([
                'success' => true,
                'portal' => 'logistics',
                'user' => $request->user()->name,
                'message' => 'Welcome to Logistics Portal',
                'data' => [
                    'active_agents' => 68,
                    'deliveries_today' => 245,
                    'success_rate' => '94%',
                    'average_delivery_time' => '2.3 hours'
                ]
            ]);
        });
    });
    
    // Delivery Agent Portal
    Route::prefix('delivery-agent')->group(function () {
        Route::get('/dashboard', function(Request $request) {
            return response()->json([
                'success' => true,
                'portal' => 'delivery_agent',
                'user' => $request->user()->name,
                'message' => 'Welcome to Delivery Agent Portal',
                'data' => [
                    'assigned_orders' => 8,
                    'completed_today' => 5,
                    'earnings_today' => 1250,
                    'current_rating' => 4.8
                ]
            ]);
        });
    });
});

// =====================================================
// 👑 CEO PORTAL - Superadmin Access & Global Analytics
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('ceo')->group(function () {
        Route::get('/dashboard', function(Request $request) {
            return response()->json([
                'success' => true,
                'portal' => 'ceo',
                'user' => $request->user()->name,
                'message' => 'Welcome to CEO Portal Dashboard',
                'data' => [
                    'system_health' => 'excellent',
                    'total_revenue_month' => 2847500,
                    'active_orders' => 1247,
                    'agent_count' => 68,
                    'critical_alerts' => 2,
                    'growth_rate' => '18.5%'
                ]
            ]);
        });
    });
});

// =====================================================
// 👥 HR PORTAL - People Management & Performance Tracking
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('hr')->group(function () {
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'hr',
                'data' => [
                    'total_employees' => 89,
                    'active_today' => 78,
                    'pending_onboarding' => 6,
                    'performance_reviews_due' => 12,
                    'disciplinary_cases' => 2
                ]
            ]);
        });
    });
});

// =====================================================
// �� FINANCE PORTAL - Payout Approvals & Financial Control
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('finance')->group(function () {
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'finance',
                'data' => [
                    'pending_payouts' => 47,
                    'total_pending_amount' => 123750,
                    'approved_today' => 28,
                    'compliance_score' => '97.8%',
                    'daily_budget_used' => '68%'
                ]
            ]);
        });
        
        Route::get('/payouts/queue', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['payout_id' => 'P001', 'agent' => 'DA-015', 'amount' => 2500, 'status' => 'pending_approval'],
                    ['payout_id' => 'P002', 'agent' => 'DA-023', 'amount' => 1875, 'status' => 'compliance_check'],
                    ['payout_id' => 'P003', 'agent' => 'DA-031', 'amount' => 3200, 'status' => 'pending_approval']
                ]
            ]);
        });
        
        Route::post('/payouts/{id}/approve', function($id) {
            return response()->json(['success' => true, 'message' => "Payout {$id} approved"]);
        });
    });
});

// =====================================================
// 📦 INVENTORY PORTAL - Stock Management & Bin Control
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('inventory')->group(function () {
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'inventory',
                'data' => [
                    'total_bins' => 68,
                    'active_bins' => 65,
                    'low_stock_alerts' => 7,
                    'pending_transfers' => 12,
                    'stock_accuracy' => '96.2%'
                ]
            ]);
        });
        
        Route::get('/bins', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['bin_id' => 'DA-001', 'location' => 'Lagos Zone A', 'stock_level' => 45, 'status' => 'optimal'],
                    ['bin_id' => 'DA-015', 'location' => 'Abuja Central', 'stock_level' => 12, 'status' => 'low_stock'],
                    ['bin_id' => 'DA-023', 'location' => 'Port Harcourt', 'stock_level' => 67, 'status' => 'optimal']
                ]
            ]);
        });
    });
});

// =====================================================
// 🔧 SHARED UTILITIES ACROSS ALL PORTALS
// =====================================================
Route::middleware('auth:sanctum')->prefix('shared')->group(function () {
    Route::get('/health/portal-status', function() {
        return response()->json([
            'success' => true,
            'data' => [
                'all_portals_operational' => true,
                'portal_status' => [
                    'ceo' => 'operational',
                    'hr' => 'operational',
                    'finance' => 'operational',
                    'inventory' => 'operational',
                    'logistics' => 'operational',
                    'delivery_agent' => 'operational',
                    'manufacturing' => 'operational'
                ]
            ]
        ]);
    });
});

// =====================================================
// 🚚 LOGISTICS PORTAL - Delivery Agent Management & SLA Tracking
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('logistics')->group(function () {
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'logistics',
                'data' => [
                    'active_agents' => 65,
                    'deliveries_today' => 287,
                    'success_rate' => '94.2%',
                    'average_delivery_time' => '2.1 hours',
                    'agents_on_route' => 38
                ]
            ]);
        });
        
        Route::get('/agents', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['agent_id' => 'DA-001', 'name' => 'John Doe', 'status' => 'active', 'deliveries_today' => 8, 'success_rate' => '96%'],
                    ['agent_id' => 'DA-015', 'name' => 'Jane Smith', 'status' => 'on_route', 'deliveries_today' => 6, 'success_rate' => '94%']
                ]
            ]);
        });
    });
});

// =====================================================
// 🏭 MANUFACTURING PORTAL - Production & Quality Control
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('manufacturing')->group(function () {
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'manufacturing',
                'data' => [
                    'active_batches' => 12,
                    'completed_today' => 8,
                    'quality_pending' => 3,
                    'production_efficiency' => '94.2%',
                    'raw_materials_low' => 2
                ]
            ]);
        });
        
        Route::get('/batches', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['batch_id' => 'B001', 'product' => 'VitaMax', 'status' => 'in_production', 'progress' => '65%'],
                    ['batch_id' => 'B002', 'product' => 'HealthPlus', 'status' => 'quality_check', 'progress' => '90%'],
                    ['batch_id' => 'B003', 'product' => 'WellnessPro', 'status' => 'completed', 'progress' => '100%']
                ]
            ]);
        });
    });
});

// =====================================================
// 🏃‍♂️ DELIVERY AGENT PORTAL - Field Operations & Order Management
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('delivery-agent')->group(function () {
        Route::get('/dashboard', function(Request $request) {
            return response()->json([
                'success' => true,
                'portal' => 'delivery_agent',
                'data' => [
                    'assigned_orders' => 6,
                    'completed_today' => 4,
                    'earnings_today' => 1580,
                    'current_rating' => 4.7,
                    'pending_deliveries' => 2
                ]
            ]);
        });
        
        Route::get('/orders/assigned', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['order_id' => 'O12345', 'customer' => 'John Customer', 'location' => 'Lagos Island', 'status' => 'pending'],
                    ['order_id' => 'O12367', 'customer' => 'Jane Buyer', 'location' => 'Victoria Island', 'status' => 'in_progress']
                ]
            ]);
        });
    });
});

// =====================================================
// 🎯 MARKETING PORTAL - Campaign Analytics & ROI Optimization
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('marketing')->group(function () {
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'marketing',
                'data' => [
                    'active_campaigns' => 8,
                    'total_impressions' => 245000,
                    'click_through_rate' => '3.2%',
                    'conversion_rate' => '12.5%',
                    'monthly_roi' => '245%'
                ]
            ]);
        });
        
        Route::get('/campaigns', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['campaign_id' => 'C001', 'name' => 'VitaMax Launch', 'status' => 'active', 'budget' => 50000, 'spent' => 32000],
                    ['campaign_id' => 'C002', 'name' => 'Wellness Week', 'status' => 'completed', 'budget' => 75000, 'spent' => 74500]
                ]
            ]);
        });
    });
});

// =====================================================
// 🔍 KYC PORTAL - Document Verification & Agent Onboarding
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('kyc')->group(function () {
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'kyc',
                'data' => [
                    'applications_pending' => 12,
                    'documents_to_verify' => 28,
                    'approved_today' => 6,
                    'rejected_today' => 2,
                    'onboarding_pipeline' => 15
                ]
            ]);
        });
        
        Route::get('/applications', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['app_id' => 'A001', 'name' => 'New Agent', 'location' => 'Lagos', 'status' => 'document_review'],
                    ['app_id' => 'A002', 'name' => 'Another Applicant', 'location' => 'Abuja', 'status' => 'background_check']
                ]
            ]);
        });
    });
});

// =====================================================
// 📊 ANALYTICS PORTAL - Business Intelligence & Reporting
// =====================================================
Route::middleware('auth:sanctum')->prefix('analytics')->group(function () {
    Route::get('/portal-usage', function() {
        return response()->json([
            'success' => true,
            'data' => [
                'most_used_portal' => 'delivery_agent',
                'portal_usage_stats' => [
                    'delivery_agent' => ['sessions' => 245, 'avg_duration' => '45 minutes'],
                    'logistics' => ['sessions' => 89, 'avg_duration' => '32 minutes'],
                    'finance' => ['sessions' => 67, 'avg_duration' => '28 minutes'],
                    'manufacturing' => ['sessions' => 54, 'avg_duration' => '38 minutes']
                ]
            ]
        ]);
    });
    
    Route::get('/business-overview', function() {
        return response()->json([
            'success' => true,
            'data' => [
                'total_orders_today' => 287,
                'revenue_today' => 156750,
                'active_delivery_agents' => 65,
                'production_efficiency' => '94.2%',
                'customer_satisfaction' => '96.1%',
                'key_metrics' => [
                    'orders_growth' => '+18.5%',
                    'revenue_growth' => '+23.2%',
                    'agent_performance' => '+5.8%'
                ]
            ]
        ]);
    });
});

// =====================================================
// ☎️ TELESALES PORTAL - Call Tracking, Lead Conversion & Performance
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('telesales')->group(function () {
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'telesales',
                'data' => [
                    'calls_today' => 47,
                    'conversions_today' => 12,
                    'conversion_rate' => '25.5%',
                    'revenue_generated' => 54000,
                    'follow_ups_pending' => 18,
                    'bonus_earned_today' => 2400
                ]
            ]);
        });

        // Lead Management
        Route::get('/leads', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['lead_id' => 'L001', 'name' => 'Potential Customer', 'phone' => '080XXXXXXXX', 'status' => 'interested', 'assigned_agent' => 'TS-001'],
                    ['lead_id' => 'L002', 'name' => 'Another Lead', 'phone' => '081XXXXXXXX', 'status' => 'follow_up', 'assigned_agent' => 'TS-002'],
                    ['lead_id' => 'L003', 'name' => 'Hot Prospect', 'phone' => '070XXXXXXXX', 'status' => 'converted', 'assigned_agent' => 'TS-001']
                ]
            ]);
        });
        
        Route::post('/leads/{leadId}/convert', function($leadId) {
            return response()->json(['success' => true, 'message' => "Lead {$leadId} converted to sale", 'bonus_earned' => 500]);
        });
        
        Route::post('/leads/{leadId}/follow-up', function($leadId) {
            return response()->json(['success' => true, 'message' => "Follow-up scheduled for lead {$leadId}"]);
        });

        // Call Management
        Route::get('/calls', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['call_id' => 'C001', 'lead' => 'L001', 'duration' => '8:45', 'outcome' => 'interested', 'agent' => 'TS-001'],
                    ['call_id' => 'C002', 'lead' => 'L002', 'duration' => '12:30', 'outcome' => 'converted', 'agent' => 'TS-002'],
                    ['call_id' => 'C003', 'lead' => 'L003', 'duration' => '5:15', 'outcome' => 'not_interested', 'agent' => 'TS-001']
                ]
            ]);
        });
        
        Route::post('/calls/log', function() {
            return response()->json(['success' => true, 'message' => 'Call logged successfully']);
        });

        // Performance & Bonus Tracking
        Route::get('/performance/metrics', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    'daily_calls' => 47,
                    'weekly_conversions' => 67,
                    'monthly_revenue' => 245000,
                    'average_call_duration' => '9:23',
                    'personal_conversion_rate' => '28.5%',
                    'team_ranking' => 2
                ]
            ]);
        });

        // Bonus & Commission Tracking
        Route::get('/bonuses', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    'earned_today' => 2400,
                    'earned_week' => 12750,
                    'earned_month' => 45600,
                    'pending_payout' => 8900,
                    'bonus_structure' => [
                        'per_conversion' => 500,
                        'monthly_target_bonus' => 15000,
                        'team_leader_bonus' => 5000
                    ]
                ]
            ]);
        });
    });
});

// =====================================================
// 💼 INVESTOR PORTAL - Read-Only Financial Performance & ROI Tracking
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('investor')->group(function () {
        // Investment Dashboard
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'investor',
                'data' => [
                    'portfolio_value' => 12500000,
                    'monthly_roi' => '3.2%',
                    'quarterly_performance' => '12.8%',
                    'total_orders_month' => 4156,
                    'revenue_growth' => '+18.5%',
                    'market_valuation' => 45000000
                ]
            ]);
        });

        // Financial Performance Metrics
        Route::get('/performance/metrics', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    'revenue_metrics' => [
                        'current_month' => 2847500,
                        'last_month' => 2401200,
                        'growth_rate' => '+18.6%'
                    ],
                    'profit_margins' => [
                        'gross_margin' => '34.2%',
                        'net_margin' => '18.7%',
                        'operating_margin' => '22.1%'
                    ],
                    'market_position' => [
                        'market_share' => '12.3%',
                        'competitive_rank' => 2,
                        'growth_vs_market' => '+5.2%'
                    ]
                ]
            ]);
        });

        // ROI Tracking & Analysis
        Route::get('/roi/tracking', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    'quarterly_roi' => [
                        'Q1_2025' => '11.2%',
                        'Q2_2025' => '12.8%',
                        'Q3_2025' => '14.1%'
                    ],
                    'annual_projection' => '15.2%',
                    'benchmark_comparison' => '+2.3% above industry',
                    'risk_metrics' => [
                        'volatility' => 'low',
                        'sharpe_ratio' => 1.85,
                        'max_drawdown' => '-3.2%'
                    ]
                ]
            ]);
        });

        // Executive Dashboard Summary
        Route::get('/executive/summary', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    'key_metrics' => [
                        'total_revenue_ytd' => 28475000,
                        'net_profit_ytd' => 5324075,
                        'customer_acquisition_cost' => 285,
                        'customer_lifetime_value' => 1850
                    ],
                    'growth_indicators' => [
                        'agent_network_growth' => '+25%',
                        'order_volume_growth' => '+32%',
                        'market_expansion' => '3 new cities',
                        'product_line_expansion' => '5 new products'
                    ],
                    'strategic_metrics' => [
                        'market_penetration' => '12.3%',
                        'brand_recognition' => '67%',
                        'customer_satisfaction' => '94.2%',
                        'agent_retention_rate' => '88%'
                    ]
                ]
            ]);
        });
    });
});

// =====================================================
// 📊 ACCOUNTANT PORTAL - Payment Confirmations, POS Reconciliation & Financial Matching
// =====================================================
Route::middleware('auth:sanctum')->prefix('portal')->group(function () {
    Route::prefix('accountant')->group(function () {
        // Accountant Dashboard
        Route::get('/dashboard', function() {
            return response()->json([
                'success' => true,
                'portal' => 'accountant',
                'data' => [
                    'payments_to_confirm' => 23,
                    'unmatched_pos' => 8,
                    'reconciliation_pending' => 15,
                    'daily_revenue' => 156750,
                    'accuracy_rate' => '98.5%',
                    'discrepancies_found' => 3
                ]
            ]);
        });

        // Payment Confirmation Queue
        Route::get('/payments/pending', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['payment_id' => 'PAY001', 'order' => 'O12345', 'amount' => 4500, 'method' => 'bank_transfer', 'status' => 'pending_confirmation'],
                    ['payment_id' => 'PAY002', 'order' => 'O12346', 'amount' => 2250, 'method' => 'pos', 'status' => 'pending_confirmation'],
                    ['payment_id' => 'PAY003', 'order' => 'O12347', 'amount' => 6750, 'method' => 'cash', 'status' => 'flagged']
                ]
            ]);
        });
        
        Route::post('/payments/{paymentId}/confirm', function($paymentId) {
            return response()->json(['success' => true, 'message' => "Payment {$paymentId} confirmed and matched"]);
        });
        
        Route::post('/payments/{paymentId}/dispute', function($paymentId) {
            return response()->json(['success' => true, 'message' => "Payment {$paymentId} flagged for dispute resolution"]);
        });

        // POS Reconciliation
        Route::get('/pos/unmatched', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    ['pos_ref' => 'POS001', 'amount' => 4500, 'timestamp' => '2025-07-13 14:30:00', 'status' => 'unmatched', 'terminal' => 'T001'],
                    ['pos_ref' => 'POS002', 'amount' => 2250, 'timestamp' => '2025-07-13 15:15:00', 'status' => 'partial_match', 'terminal' => 'T002'],
                    ['pos_ref' => 'POS003', 'amount' => 6750, 'timestamp' => '2025-07-13 16:00:00', 'status' => 'matched', 'terminal' => 'T001']
                ]
            ]);
        });
        
        Route::post('/pos/match', function() {
            return response()->json(['success' => true, 'message' => 'POS transaction matched successfully']);
        });

        // Financial Reconciliation Reports
        Route::get('/reconciliation/daily', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    'expected_revenue' => 156750,
                    'confirmed_revenue' => 151200,
                    'pending_confirmation' => 5550,
                    'discrepancies' => 3,
                    'reconciliation_rate' => '96.5%',
                    'total_transactions' => 287
                ]
            ]);
        });
        
        Route::get('/reports/financial-summary', function() {
            return response()->json([
                'success' => true,
                'data' => [
                    'daily_summary' => [
                        'total_transactions' => 287,
                        'total_revenue' => 156750,
                        'payment_methods' => [
                            'pos' => '68%',
                            'bank_transfer' => '25%',
                            'cash' => '7%'
                        ],
                        'reconciliation_accuracy' => '98.5%'
                    ]
                ]
            ]);
        });
    });
});

// Health check for Railway
Route::get('/health', function () {
    try {
        DB::connection()->getPdo();
        $dbStatus = 'connected';
    } catch (\Exception $e) {
        $dbStatus = 'disconnected';
    }
    
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'database' => $dbStatus,
        'app' => config('app.name')
    ]);
});

// Health check for Railway
Route::get('/health', function () {
    try {
        DB::connection()->getPdo();
        $dbStatus = 'connected';
    } catch (\Exception $e) {
        $dbStatus = 'disconnected';
    }
    
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'database' => $dbStatus,
        'app' => config('app.name')
    ]);
});

// Health check endpoint for Railway
Route::get('/health', function () {
    try {
        // Test database connection
        DB::connection()->getPdo();
        $dbStatus = 'connected';
    } catch (\Exception $e) {
        $dbStatus = 'disconnected';
    }

    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'database' => $dbStatus,
        'app' => config('app.name'),
        'env' => config('app.env')
    ]);
});
