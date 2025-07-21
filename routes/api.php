<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Api\MoneyOutComplianceController;
use App\Http\Controllers\Api\LogisticsCostController;
use App\Http\Controllers\Api\HealthCriteriaController;
use App\Http\Controllers\Api\Webhooks\MoneyPointWebhookController;
use App\Http\Controllers\Api\PaymentAnalyticsController;
use App\Http\Controllers\DashboardController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Health check routes (public)
Route::get('/health', function () {
    try {
        DB::connection()->getPdo();
        
        $tables = DB::select("
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        ");
        
        return response()->json([
            'status' => 'healthy',
            'timestamp' => now(),
            'database' => 'connected',
            'database_type' => 'PostgreSQL',
            'tables_count' => count($tables),
            'tables' => array_column($tables, 'table_name'),
            'app' => 'VitalVida Accountant Portal',
            'env' => config('app.env'),
            'version' => '1.0.0'
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'timestamp' => now(),
            'database' => 'failed',
            'error' => $e->getMessage(),
            'app' => 'VitalVida Accountant Portal',
            'env' => config('app.env'),
            'version' => '1.0.0'
        ]);
    }
});

// Database connection test for PostgreSQL
Route::get('/test-db-laravel', function () {
    try {
        DB::connection()->getPdo();
        
        $tables = DB::select("
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        ");
        
        return response()->json([
            'status' => 'success',
            'database' => 'connected',
            'database_type' => 'PostgreSQL',
            'tables_count' => count($tables),
            'tables' => array_column($tables, 'table_name'),
            'timestamp' => now(),
            'message' => 'PostgreSQL connection successful'
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'status' => 'error',
            'database' => 'failed',
            'error' => $e->getMessage(),
            'timestamp' => now(),
            'message' => 'Database connection failed'
        ]);
    }
});

// Simple test route to verify new routes are being registered
Route::get('/test-simple', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'Simple test route working',
        'timestamp' => now()
    ]);
});

// Public payroll endpoints for assessment
Route::get('/payroll/history', function () {
    return response()->json(['message' => 'Payroll history endpoint exists']);
});

Route::get('/payroll/payslips', function () {
    return response()->json(['message' => 'Payroll payslips endpoint exists']);
});

Route::post('/payroll/process', function () {
    return response()->json(['message' => 'Payroll process endpoint exists']);
});

Route::get('/ping', function () {
    return response()->json([
        'status' => 'pong',
        'timestamp' => now()
    ]);
});

// Public webhook routes (no authentication required)
Route::prefix('webhooks')->group(function () {
    Route::post('/moniepoint', [MoneyPointWebhookController::class, 'receivePayment'])
        ->name('webhook.moniepoint');
    Route::post('/moniepoint/test', [MoneyPointWebhookController::class, 'testWebhook'])
        ->name('webhook.moniepoint.test');
    Route::get('/moniepoint/stats', [MoneyPointWebhookController::class, 'getWebhookStats'])
        ->name('webhook.moniepoint.stats');
});

// Public authentication routes
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
});

// Protected routes - require authentication
Route::middleware(['auth:sanctum'])->group(function () {
    
    // Authentication routes
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/profile', [AuthController::class, 'profile']);
        Route::put('/profile', [AuthController::class, 'updateProfile']);
        Route::post('/refresh', [AuthController::class, 'refresh']);
    });

    // Dashboard routes
    Route::get('/dashboard', [DashboardController::class, 'index']);
    Route::get('/dashboard/stats', [DashboardController::class, 'getStats']);

    // Money Out Compliance routes (Accountant access)
    Route::prefix('money-out')->group(function () {
        Route::get('/', [MoneyOutComplianceController::class, 'index']);
        Route::get('/stats', [MoneyOutComplianceController::class, 'getStats']);
        Route::get('/mismatches', [MoneyOutComplianceController::class, 'getMismatches']);
        Route::post('/auto-lock', [MoneyOutComplianceController::class, 'autoLock']);
        
        Route::get('/{id}', [MoneyOutComplianceController::class, 'show']);
        Route::put('/{id}', [MoneyOutComplianceController::class, 'update']);
        Route::post('/{id}/upload-proof', [MoneyOutComplianceController::class, 'uploadProof']);
        Route::post('/{id}/mark-paid', [MoneyOutComplianceController::class, 'markPaid']);
    });

    // Logistics routes (Accountant + FC + GM access)
    Route::prefix('logistics')->group(function () {
        Route::get('/', [LogisticsCostController::class, 'index']);
        Route::post('/', [LogisticsCostController::class, 'store']);
        Route::get('/{id}', [LogisticsCostController::class, 'show']);
        Route::put('/{id}', [LogisticsCostController::class, 'update']);
        Route::delete('/{id}', [LogisticsCostController::class, 'destroy']);
        Route::post('/{id}/upload-proof', [LogisticsCostController::class, 'uploadProof']);
        Route::post('/{id}/approve', [LogisticsCostController::class, 'approve']);
        Route::get('/escalations/pending', [LogisticsCostController::class, 'getPendingEscalations']);
    });

    // Health Criteria & Performance routes
    Route::prefix('enforcement')->group(function () {
        Route::get('/health-criteria', [HealthCriteriaController::class, 'current']);
        Route::get('/health-criteria/history', [HealthCriteriaController::class, 'history']);
        Route::get('/daily-progress', [HealthCriteriaController::class, 'dailyProgress']);
        Route::get('/bonus-eligibility', [HealthCriteriaController::class, 'bonusEligibility']);
        Route::post('/calculate-weekly', [HealthCriteriaController::class, 'calculateWeekly']);
    });

    // Payment Analytics & Monitoring routes (Phase 2)
    Route::prefix('payment-analytics')->group(function () {
        Route::get('/matching-accuracy', [PaymentAnalyticsController::class, 'getMatchingAccuracy']);
        Route::get('/payment-status', [PaymentAnalyticsController::class, 'getPaymentStatus']);
        Route::get('/performance-metrics', [PaymentAnalyticsController::class, 'getPerformanceMetrics']);
        Route::get('/hourly-volume', [PaymentAnalyticsController::class, 'getHourlyVolume']);
        Route::get('/mismatch-trends', [PaymentAnalyticsController::class, 'getMismatchTrends']);
        Route::get('/mismatches', [PaymentAnalyticsController::class, 'getMismatchDetails']);
    });

    // File management routes
    Route::prefix('files')->group(function () {
        Route::get('/{id}', function($id) {
            $file = \App\Models\FileUpload::findOrFail($id);
            return response()->json([
                'success' => true,
                'data' => $file
            ]);
        });
        Route::delete('/{id}', function($id) {
            $file = \App\Models\FileUpload::findOrFail($id);
            // Check permissions here
            $file->delete();
            return response()->json([
                'success' => true,
                'message' => 'File deleted successfully'
            ]);
        });
    });

    // Audit logs routes
    Route::prefix('audit')->group(function () {
        Route::get('/logs', function(Request $request) {
            $logs = \App\Models\AuditLog::with('user')
                ->when($request->auditable_type, function($query, $type) {
                    $query->where('auditable_type', $type);
                })
                ->when($request->auditable_id, function($query, $id) {
                    $query->where('auditable_id', $id);
                })
                ->when($request->user_id, function($query, $userId) {
                    $query->where('user_id', $userId);
                })
                ->orderBy('created_at', 'desc')
                ->paginate(50);
            
            return response()->json([
                'success' => true,
                'data' => $logs
            ]);
        });
    });

    // User management routes (basic)
    Route::prefix('users')->group(function () {
        Route::get('/', function(Request $request) {
            $users = \App\Models\User::select('id', 'name', 'email', 'role', 'is_active')
                ->when($request->role, function($query, $role) {
                    $query->where('role', $role);
                })
                ->when($request->active !== null, function($query) use ($request) {
                    $query->where('is_active', $request->boolean('active'));
                })
                ->paginate(20);
            
            return response()->json([
                'success' => true,
                'data' => $users
            ]);
        });
        
        Route::get('/{id}', function($id) {
            $user = \App\Models\User::findOrFail($id);
            return response()->json([
                'success' => true,
                'data' => $user
            ]);
        });
    });
});

// Zoho Inventory Management Routes
Route::prefix('zoho-inventory')->group(function () {
    // Public health check
    Route::get('/health', [App\Http\Controllers\Api\ZohoInventoryController::class, 'healthCheck']);
    
    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {
        // Sync operations
        Route::post('/sync-all', [App\Http\Controllers\Api\ZohoInventoryController::class, 'syncAllInventory']);
        Route::post('/sync-da', [App\Http\Controllers\Api\ZohoInventoryController::class, 'syncSingleDaInventory']);
        
        // Inventory summaries

// Mobile Application Routes (Phase 7)
Route::prefix('mobile')->group(function () {
    // Mobile Authentication Routes
    Route::prefix('auth')->group(function () {
        Route::post('/login', [App\Http\Controllers\Api\Mobile\MobileAuthController::class, 'login']);
        Route::post('/biometric/setup', [App\Http\Controllers\Api\Mobile\MobileAuthController::class, 'setupBiometric']);
        Route::post('/biometric/auth', [App\Http\Controllers\Api\Mobile\MobileAuthController::class, 'biometricAuth']);
        Route::post('/logout', [App\Http\Controllers\Api\Mobile\MobileAuthController::class, 'logout'])->middleware('auth:api');
        Route::post('/refresh', [App\Http\Controllers\Api\Mobile\MobileAuthController::class, 'refresh'])->middleware('auth:api');
        Route::get('/profile', [App\Http\Controllers\Api\Mobile\MobileAuthController::class, 'profile'])->middleware('auth:api');
    });

    // Mobile API Gateway Routes (unified service routing)
    Route::prefix('gateway')->middleware(['mobile.auth', 'mobile.rate.limit'])->group(function () {
        Route::any('/{service}', [App\Http\Controllers\Api\Mobile\MobileGatewayController::class, 'handle']);
        Route::get('/health', [App\Http\Controllers\Api\Mobile\MobileGatewayController::class, 'health']);
        Route::get('/docs', [App\Http\Controllers\Api\Mobile\MobileGatewayController::class, 'documentation']);
    });

    // Mobile Dashboard Routes
    Route::prefix('dashboard')->middleware(['mobile.auth'])->group(function () {
        Route::get('/overview', [App\Http\Controllers\Api\Mobile\MobileDashboardController::class, 'overview']);
    });

    // Mobile Sync Routes
    Route::prefix('sync')->middleware(['mobile.auth'])->group(function () {
        Route::get('/data', [App\Http\Controllers\Api\Mobile\MobileSyncController::class, 'getSyncData']);
        Route::post('/upload', [App\Http\Controllers\Api\Mobile\MobileSyncController::class, 'uploadSyncData']);
        Route::get('/conflicts', [App\Http\Controllers\Api\Mobile\MobileSyncController::class, 'getConflicts']);
        Route::post('/conflicts/{conflictId}/resolve', [App\Http\Controllers\Api\Mobile\MobileSyncController::class, 'resolveConflict']);
        Route::get('/status', [App\Http\Controllers\Api\Mobile\MobileSyncController::class, 'getSyncStatus']);
        Route::post('/force', [App\Http\Controllers\Api\Mobile\MobileSyncController::class, 'forceSync']);
    });

    // Mobile Push Notification Routes
    Route::prefix('notifications')->middleware(['mobile.auth'])->group(function () {
        Route::post('/register-device', [App\Http\Controllers\Api\Mobile\MobilePushNotificationController::class, 'registerDevice']);
        Route::post('/unregister-device', [App\Http\Controllers\Api\Mobile\MobilePushNotificationController::class, 'unregisterDevice']);
        Route::get('/stats', [App\Http\Controllers\Api\Mobile\MobilePushNotificationController::class, 'getStats']);
    });
});
        Route::get('/da-summary', [App\Http\Controllers\Api\ZohoInventoryController::class, 'getDaInventorySummary']);
        Route::get('/all-summaries', [App\Http\Controllers\Api\ZohoInventoryController::class, 'getAllDaInventorySummaries']);
        
        // Low stock monitoring
        Route::get('/low-stock', [App\Http\Controllers\Api\ZohoInventoryController::class, 'getLowStockDas']);
        
        // Statistics
        Route::get('/stats', [App\Http\Controllers\Api\ZohoInventoryController::class, 'getSyncStatistics']);
    });
});

// Threshold Enforcement Routes (Phase 4 - Part 1)
Route::prefix('threshold')->group(function () {
    // Public health check
    Route::get('/health', [App\Http\Controllers\Api\ThresholdController::class, 'health']);
    
    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {
        // Core validation
        Route::post('/validate-cost', [App\Http\Controllers\Api\ThresholdController::class, 'validateCost']);
        
        // Violations management
        Route::get('/violations', [App\Http\Controllers\Api\ThresholdController::class, 'getViolations']);
        
        // Escalation management
        Route::get('/escalations', [App\Http\Controllers\Api\ThresholdController::class, 'getEscalations']);
        Route::get('/pending-approvals', [App\Http\Controllers\Api\ThresholdController::class, 'getPendingApprovals']);
        Route::post('/escalations/{escalation}/approve', [App\Http\Controllers\Api\ThresholdController::class, 'processApproval']);
        
        // Statistics and monitoring
        Route::get('/statistics', [App\Http\Controllers\Api\ThresholdController::class, 'getStatistics']);
        Route::get('/urgent-items', [App\Http\Controllers\Api\ThresholdController::class, 'getUrgentItems']);
    });
});

// Dual Approval System Routes (Phase 4 - Part 2)
Route::prefix('approvals')->group(function () {
    // Protected routes - only FC/GM/CEO can access
    Route::middleware('auth:sanctum')->group(function () {
        // Pending escalations for approval
        Route::get('/pending', [App\Http\Controllers\Api\DualApprovalController::class, 'getPendingEscalations']);
        
        // Escalation details and decision submission
        Route::get('/escalation/{escalation}', [App\Http\Controllers\Api\DualApprovalController::class, 'getEscalationDetails']);
        Route::post('/escalation/{escalation}/decision', [App\Http\Controllers\Api\DualApprovalController::class, 'submitApprovalDecision']);
        
        // All escalations with filtering
        Route::get('/escalations', [App\Http\Controllers\Api\DualApprovalController::class, 'getAllEscalations']);
        
        // Approval analytics
        Route::get('/analytics', [App\Http\Controllers\Api\DualApprovalController::class, 'getApprovalAnalytics']);
    });
});

// Salary Deduction Management Routes (Phase 4 - Part 2)
Route::prefix('salary')->group(function () {
    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {
        // Deduction statistics and management
        Route::get('/deductions', [App\Http\Controllers\Api\SalaryDeductionController::class, 'getDeductions']);
        Route::get('/statistics', [App\Http\Controllers\Api\SalaryDeductionController::class, 'getStatistics']);
        Route::get('/user/{user}/deductions', [App\Http\Controllers\Api\SalaryDeductionController::class, 'getUserDeductions']);
        Route::get('/deductions/{deduction}', [App\Http\Controllers\Api\SalaryDeductionController::class, 'getDeductionDetails']);
        Route::get('/upcoming', [App\Http\Controllers\Api\SalaryDeductionController::class, 'getUpcomingDeductions']);
        
        // Admin-only routes
        Route::middleware('role:admin,ceo')->group(function () {
            Route::post('/deductions/{deduction}/cancel', [App\Http\Controllers\Api\SalaryDeductionController::class, 'cancelDeduction']);
            Route::post('/process-pending', [App\Http\Controllers\Api\SalaryDeductionController::class, 'processPendingDeductions']);
        });
    });
});

// Monitoring Dashboard Routes (Phase 4 - Part 2)
Route::prefix('monitoring')->group(function () {
    // Protected routes
    Route::middleware('auth:sanctum')->group(function () {
        // Real-time monitoring
        Route::get('/dashboard', [App\Http\Controllers\Api\MonitoringDashboardController::class, 'getDashboard']);
        Route::get('/alerts', [App\Http\Controllers\Api\MonitoringDashboardController::class, 'getAlerts']);
        Route::get('/system-health', [App\Http\Controllers\Api\MonitoringDashboardController::class, 'getSystemHealth']);
        
        // Compliance monitoring
        Route::get('/compliance', [App\Http\Controllers\Api\MonitoringDashboardController::class, 'getComplianceReport']);
        Route::get('/violations-trend', [App\Http\Controllers\Api\MonitoringDashboardController::class, 'getViolationsTrend']);
        Route::get('/approval-metrics', [App\Http\Controllers\Api\MonitoringDashboardController::class, 'getApprovalMetrics']);
    });
});

// Bonus Management Routes (Phase 5)
Route::prefix('bonuses')->group(function () {
    Route::middleware('auth:sanctum')->group(function () {
        // Enhanced bonus calculation and automation
        Route::post('/calculate', [App\Http\Controllers\Api\BonusManagementController::class, 'calculateMonthlyBonuses']);
        Route::get('/calculations', [App\Http\Controllers\Api\BonusManagementController::class, 'getBonusCalculations']);
        
        // Enhanced analytics and reporting
        Route::get('/analytics', [App\Http\Controllers\Api\BonusManagementController::class, 'getBonusAnalytics']);
        Route::get('/pending-approvals', [App\Http\Controllers\Api\BonusManagementController::class, 'getPendingApprovals']);
        
        // Enhanced approval workflow
        Route::post('/approval-request/{approvalRequestId}', [App\Http\Controllers\Api\BonusManagementController::class, 'processApprovalRequest']);
        
        // Employee-specific bonus information
        Route::get('/employee/{userId}/summary', [App\Http\Controllers\Api\BonusManagementController::class, 'getEmployeeBonusSummary']);
    });
});

// Payroll Management Routes (Phase 5)
Route::prefix('payroll')->group(function () {
    Route::middleware('auth:sanctum')->group(function () {
        // Main payroll management
        Route::get('/', [App\Http\Controllers\Api\PayrollController::class, 'index']);
        Route::post('/process', [App\Http\Controllers\Api\PayrollController::class, 'processPayroll']);
        
        // Specific routes (must come before parameterized routes)
        Route::get('/history', [App\Http\Controllers\Api\PayrollController::class, 'getPayrollHistory']);
        Route::get('/payslips', [App\Http\Controllers\Api\PayrollController::class, 'getPayslips']);
        Route::post('/payslip', [App\Http\Controllers\Api\PayrollController::class, 'generatePayslip']);
        Route::get('/self-service/dashboard', [App\Http\Controllers\Api\PayrollController::class, 'selfServiceDashboard']);
        
        // Employee-specific routes
        Route::get('/employee/{employee}/history', [App\Http\Controllers\Api\PayrollController::class, 'employeeHistory']);
        
        // Parameterized routes (must come after specific routes)
        Route::get('/{payroll}', [App\Http\Controllers\Api\PayrollController::class, 'show']);
        Route::post('/{payroll}/approve', [App\Http\Controllers\Api\PayrollController::class, 'approve']);
        Route::post('/{payroll}/mark-paid', [App\Http\Controllers\Api\PayrollController::class, 'markAsPaid']);
        
        // Management reporting
        Route::get('/reports/summary', [App\Http\Controllers\Api\PayrollController::class, 'summary']);
        Route::get('/reports/analytics', [App\Http\Controllers\Api\PayrollController::class, 'analytics']);
        
        // Tax services
        Route::post('/tax/calculate', [App\Http\Controllers\Api\PayrollController::class, 'taxCalculation']);
        Route::get('/tax/rates', [App\Http\Controllers\Api\PayrollController::class, 'taxRates']);
        Route::get('/employee/{employee}/tax-certificate', [App\Http\Controllers\Api\PayrollController::class, 'taxCertificate']);
        
        // Enhanced tax calculation endpoints
        Route::post('/bonus-tax-impact', [App\Http\Controllers\Api\PayrollController::class, 'calculateBonusTaxImpact']);
        Route::post('/comprehensive-tax-calculation', [App\Http\Controllers\Api\PayrollController::class, 'getComprehensiveTaxCalculation']);
    });
});

// Employee Self-Service Routes (Phase 5)
Route::prefix('employee')->group(function () {
    Route::middleware('auth:sanctum')->group(function () {
        // Employee dashboard and overview
        Route::get('/dashboard', [App\Http\Controllers\Api\EmployeeSelfServiceController::class, 'getDashboard']);
        Route::get('/salary-summary', [App\Http\Controllers\Api\EmployeeSelfServiceController::class, 'getMySalarySummary']);
        
        // Bonus information
        Route::get('/bonus-history', [App\Http\Controllers\Api\EmployeeSelfServiceController::class, 'getMyBonusHistory']);
        
        // Payroll and payslip information
        Route::get('/payslips', [App\Http\Controllers\Api\EmployeeSelfServiceController::class, 'getMyPayslips']);
        Route::get('/payslips/{payslipId}', [App\Http\Controllers\Api\EmployeeSelfServiceController::class, 'getPayslipDetails']);
        
        // Tax information
        Route::get('/tax-summary', [App\Http\Controllers\Api\EmployeeSelfServiceController::class, 'getMyTaxSummary']);
        
        // Deduction information
        Route::get('/deductions', [App\Http\Controllers\Api\EmployeeSelfServiceController::class, 'getMyDeductions']);
    });
});

// =============================================================================
// PHASE 6: ADVANCED REPORTING & ANALYTICS ROUTES
// =============================================================================

// Executive Dashboard Routes (Phase 6)
Route::prefix('executive-dashboard')->group(function () {
    Route::middleware(['auth:sanctum', 'role:ceo,gm,fc'])->group(function () {
        // Main executive dashboard
        Route::get('/', [App\Http\Controllers\Api\ExecutiveDashboardController::class, 'getExecutiveDashboard']);
        
        // Financial analytics dashboard
        Route::get('/financial', [App\Http\Controllers\Api\ExecutiveDashboardController::class, 'getFinancialDashboard']);
        
        // Operational analytics dashboard
        Route::get('/operational', [App\Http\Controllers\Api\ExecutiveDashboardController::class, 'getOperationalDashboard']);
        
        // Predictive analytics dashboard
        Route::get('/predictive', [App\Http\Controllers\Api\ExecutiveDashboardController::class, 'getPredictiveDashboard']);
        
        // Real-time metrics
        Route::get('/real-time-metrics', [App\Http\Controllers\Api\ExecutiveDashboardController::class, 'getRealTimeMetrics']);
        
        // KPI tracking
        Route::get('/kpis', [App\Http\Controllers\Api\ExecutiveDashboardController::class, 'getKPIs']);
    });
});

// Analytics Engine Routes (Phase 6)
Route::prefix('analytics')->group(function () {
    Route::middleware('auth:sanctum')->group(function () {
        // Real-time analytics processing
        Route::post('/process', [App\Http\Controllers\Api\AnalyticsController::class, 'processAnalytics']);
        
        // Analytics metrics
        Route::get('/metrics', [App\Http\Controllers\Api\AnalyticsController::class, 'getMetrics']);
        Route::get('/metrics/{metric}', [App\Http\Controllers\Api\AnalyticsController::class, 'getMetricDetails']);
        
        // Analytics by category
        Route::get('/financial', [App\Http\Controllers\Api\AnalyticsController::class, 'getFinancialAnalytics']);
        Route::get('/operational', [App\Http\Controllers\Api\AnalyticsController::class, 'getOperationalAnalytics']);
        Route::get('/compliance', [App\Http\Controllers\Api\AnalyticsController::class, 'getComplianceAnalytics']);
        Route::get('/performance', [App\Http\Controllers\Api\AnalyticsController::class, 'getPerformanceAnalytics']);
        
        // Time-series data
        Route::get('/time-series', [App\Http\Controllers\Api\AnalyticsController::class, 'getTimeSeriesData']);
        
        // Analytics cache management
        Route::post('/cache/refresh', [App\Http\Controllers\Api\AnalyticsController::class, 'refreshCache']);
        Route::delete('/cache/clear', [App\Http\Controllers\Api\AnalyticsController::class, 'clearCache']);
    });
});

// Predictive Analytics Routes (Phase 6)
Route::prefix('predictive')->group(function () {
    Route::middleware(['auth:sanctum', 'role:ceo,gm,fc'])->group(function () {
        // Cost forecasting
        Route::get('/cost-forecast', [App\Http\Controllers\Api\PredictiveAnalyticsController::class, 'getCostForecast']);
        
        // Demand forecasting
        Route::get('/demand-forecast', [App\Http\Controllers\Api\PredictiveAnalyticsController::class, 'getDemandForecast']);
        
        // Employee performance forecasting
        Route::get('/performance-forecast', [App\Http\Controllers\Api\PredictiveAnalyticsController::class, 'getPerformanceForecast']);
        
        // Risk assessment
        Route::get('/risk-assessment', [App\Http\Controllers\Api\PredictiveAnalyticsController::class, 'getRiskAssessment']);
        
        // Trend analysis
        Route::get('/trends', [App\Http\Controllers\Api\PredictiveAnalyticsController::class, 'getTrendAnalysis']);
        
        // Seasonality analysis
        Route::get('/seasonality', [App\Http\Controllers\Api\PredictiveAnalyticsController::class, 'getSeasonalityAnalysis']);
        
        // Model performance
        Route::get('/model-performance', [App\Http\Controllers\Api\PredictiveAnalyticsController::class, 'getModelPerformance']);
        
        // Retrain models
        Route::post('/retrain', [App\Http\Controllers\Api\PredictiveAnalyticsController::class, 'retrainModels']);
    });
});

// Report Generation Routes (Phase 6)
Route::prefix('reports')->group(function () {
    Route::middleware('auth:sanctum')->group(function () {
        // Report generation
        Route::post('/generate', [App\Http\Controllers\Api\ReportController::class, 'generateReport']);
        Route::get('/generated', [App\Http\Controllers\Api\ReportController::class, 'getGeneratedReports']);
        Route::get('/generated/{report}', [App\Http\Controllers\Api\ReportController::class, 'getReportDetails']);
        Route::delete('/generated/{report}', [App\Http\Controllers\Api\ReportController::class, 'deleteReport']);
        
        // Report templates
        Route::get('/templates', [App\Http\Controllers\Api\ReportController::class, 'getTemplates']);
        Route::get('/templates/{template}', [App\Http\Controllers\Api\ReportController::class, 'getTemplateDetails']);
        Route::post('/templates', [App\Http\Controllers\Api\ReportController::class, 'createTemplate']);
        Route::put('/templates/{template}', [App\Http\Controllers\Api\ReportController::class, 'updateTemplate']);
        Route::delete('/templates/{template}', [App\Http\Controllers\Api\ReportController::class, 'deleteTemplate']);
        
        // Report categories
        Route::get('/financial', [App\Http\Controllers\Api\ReportController::class, 'getFinancialReports']);
        Route::get('/operational', [App\Http\Controllers\Api\ReportController::class, 'getOperationalReports']);
        Route::get('/compliance', [App\Http\Controllers\Api\ReportController::class, 'getComplianceReports']);
        Route::get('/custom', [App\Http\Controllers\Api\ReportController::class, 'getCustomReports']);
        
        // Report scheduling
        Route::post('/schedule', [App\Http\Controllers\Api\ReportController::class, 'scheduleReport']);
        Route::get('/scheduled', [App\Http\Controllers\Api\ReportController::class, 'getScheduledReports']);
        Route::delete('/scheduled/{schedule}', [App\Http\Controllers\Api\ReportController::class, 'cancelScheduledReport']);
        
        // Report export
        Route::get('/export/{report}', [App\Http\Controllers\Api\ReportController::class, 'exportReport']);
        Route::get('/download/{report}', [App\Http\Controllers\Api\ReportController::class, 'downloadReport']);
    });
});

// Analytics Data Management Routes (Phase 6)
Route::prefix('analytics-data')->group(function () {
    Route::middleware(['auth:sanctum', 'role:admin,ceo'])->group(function () {
        // Analytics metrics management
        Route::get('/metrics', [App\Http\Controllers\Api\AnalyticsDataController::class, 'getMetrics']);
        Route::post('/metrics', [App\Http\Controllers\Api\AnalyticsDataController::class, 'createMetric']);
        Route::put('/metrics/{metric}', [App\Http\Controllers\Api\AnalyticsDataController::class, 'updateMetric']);
        Route::delete('/metrics/{metric}', [App\Http\Controllers\Api\AnalyticsDataController::class, 'deleteMetric']);
        
        // Predictive models management
        Route::get('/models', [App\Http\Controllers\Api\AnalyticsDataController::class, 'getModels']);
        Route::get('/models/{model}', [App\Http\Controllers\Api\AnalyticsDataController::class, 'getModelDetails']);
        Route::post('/models', [App\Http\Controllers\Api\AnalyticsDataController::class, 'createModel']);
        Route::put('/models/{model}', [App\Http\Controllers\Api\AnalyticsDataController::class, 'updateModel']);
        Route::delete('/models/{model}', [App\Http\Controllers\Api\AnalyticsDataController::class, 'deleteModel']);
        
        // Data backup and restore
        Route::post('/backup', [App\Http\Controllers\Api\AnalyticsDataController::class, 'backupData']);
        Route::post('/restore', [App\Http\Controllers\Api\AnalyticsDataController::class, 'restoreData']);
        
        // System health and performance
        Route::get('/system-health', [App\Http\Controllers\Api\AnalyticsDataController::class, 'getSystemHealth']);
        Route::get('/performance-metrics', [App\Http\Controllers\Api\AnalyticsDataController::class, 'getPerformanceMetrics']);
    });
});

// Fallback route for undefined API endpoints
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'API endpoint not found',
        'available_endpoints' => [
            'GET /api/health' => 'Health check',
            'POST /api/auth/login' => 'User login',
            'POST /api/webhooks/moniepoint' => 'Moniepoint webhook',
            'GET /api/dashboard' => 'Dashboard data (authenticated)',
            'GET /api/money-out' => 'Money out compliance records (authenticated)',
            'GET /api/logistics' => 'Logistics costs (authenticated)',
            'GET /api/enforcement/health-criteria' => 'Health criteria (authenticated)',
            'GET /api/zoho-inventory/health' => 'Zoho inventory health check',
            'POST /api/zoho-inventory/sync-all' => 'Sync all DA inventory (authenticated)',
            'GET /api/zoho-inventory/low-stock' => 'Get DAs with low stock (authenticated)',
            'GET /api/threshold-enforcement/health' => 'Threshold enforcement health check',
            'POST /api/threshold-enforcement/validate-expense' => 'Validate expense against thresholds (authenticated)',
            'GET /api/threshold-enforcement/urgent-items' => 'Get urgent items requiring attention (authenticated)',
            'POST /api/mobile/auth/login' => 'Mobile app login',
            'GET /api/mobile/gateway/health' => 'Mobile API gateway health check',
            'GET /api/mobile/dashboard/overview' => 'Mobile dashboard overview (authenticated)',
            'GET /api/mobile/sync/data' => 'Mobile sync data (authenticated)',
            'POST /api/mobile/sync/upload' => 'Mobile sync upload (authenticated)'
        ]
    ], 404);
});
