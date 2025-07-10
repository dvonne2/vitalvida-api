<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\InventoryController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/dashboard/summary', [DashboardController::class, 'getSummary']);

Route::prefix('inventory')->group(function () {
    Route::get('/dashboard', [InventoryController::class, 'getDashboard']);
    Route::get('/insights', [InventoryController::class, 'getInsights']);
});
Route::get("/strikes/log", [App\Http\Controllers\StrikeController::class, "getLog"]);
Route::get("/performance/summary", [App\Http\Controllers\PerformanceController::class, "getSummary"]);
Route::post("/inventory/photo-verification/entry", [App\Http\Controllers\PhotoVerificationController::class, "create"]);
Route::get("/inventory/photo-verification/comparison", [App\Http\Controllers\PhotoVerificationController::class, "getComparison"]);
Route::get("/inventory/photo-verification/flags", [App\Http\Controllers\PhotoVerificationController::class, "getFlags"]);
Route::post("/audit/resolve", [App\Http\Controllers\AuditController::class, "resolveDiscrepancy"]);
Route::get("/audit/fc-review", [App\Http\Controllers\AuditController::class, "getPendingReview"]);
Route::post("/audit/fc-review", [App\Http\Controllers\AuditController::class, "processReview"]);
Route::get("/analytics/aging-report", [App\Http\Controllers\AnalyticsController::class, "getAgingReport"]);
Route::get("/inventory/adjustments/log", [App\Http\Controllers\InventoryController::class, "getAdjustmentsLog"]);
Route::get("/delivery-agents/performance", [App\Http\Controllers\DeliveryAgentController::class, "getPerformanceReport"]);
Route::get("/inventorymanager/performance/summary", [App\Http\Controllers\PerformanceController::class, "getInventoryManagerSummary"]);
Route::get("/delivery-agents/payment-match", [App\Http\Controllers\DeliveryAgentController::class, "getPaymentMatchReport"]);
Route::get("/returns/misreporting", [App\Http\Controllers\ReturnsController::class, "getMisreportedReturns"]);
Route::get("/strikes/da/{id}", [App\Http\Controllers\StrikeController::class, "getStrikeLog"]);
Route::get("/insights/bin-suggestions", [App\Http\Controllers\InsightController::class, "getBinSuggestions"]);
Route::get("/audit/logs", [App\Http\Controllers\AuditController::class, "getLogs"]);
Route::get("/knowledge/inventory", [App\Http\Controllers\KnowledgeController::class, "getInventoryGuide"]);
Route::get("/delivery-agents/profile/{id}", [App\Http\Controllers\DeliveryAgentController::class, "getProfile"]);
