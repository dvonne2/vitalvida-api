<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\InventoryController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// SECURE INVENTORY ROUTES - PAYMENT + OTP REQUIRED
Route::middleware(['auth:sanctum', 'inventory.security'])->group(function () {
    // Inventory deduction - NOW REQUIRES PAYMENT + OTP
    Route::post('/inventory/deduct', [InventoryController::class, 'deductInventory'])
        ->middleware('throttle:10,1');

    // Check if order is ready for deduction
    Route::get('/inventory/check-eligibility', [InventoryController::class, 'checkDeductionEligibility'])
        ->middleware('throttle:30,1');

    // Audit trail
    Route::get('/inventory/audit/{orderNumber}', [InventoryController::class, 'getAuditTrail'])
        ->middleware('throttle:20,1');
});

// DELIVERY CONFIRMATION - TRIGGERS AUTOMATIC INVENTORY DEDUCTION
use App\Http\Controllers\DeliveryController;

Route::middleware(['auth:sanctum'])->group(function () {
    // Confirm delivery - AUTOMATICALLY triggers inventory deduction
    Route::post('/delivery/confirm', [DeliveryController::class, 'confirmDelivery'])
        ->middleware('throttle:5,1');

    // Check delivery status
    Route::get('/delivery/status/{orderNumber}', [DeliveryController::class, 'getDeliveryStatus'])
        ->middleware('throttle:20,1');
});

// INVENTORY MOVEMENT REPORTING - READ-ONLY ACCESS
use App\Http\Controllers\InventoryMovementController;

Route::middleware(['auth:sanctum'])->group(function () {
    // BIN movement history
    Route::get('/movements/bin/{binId}', [InventoryMovementController::class, 'getBinMovements'])
        ->middleware('throttle:60,1');

    // Item movement history
    Route::get('/movements/item/{itemId}', [InventoryMovementController::class, 'getItemMovements'])
        ->middleware('throttle:60,1');

    // Order movement details
    Route::get('/movements/order/{orderNumber}', [InventoryMovementController::class, 'getOrderMovements'])
        ->middleware('throttle:60,1');

    // Movement summary and analytics
    Route::get('/movements/summary', [InventoryMovementController::class, 'getMovementSummary'])
        ->middleware('throttle:30,1');

    // Recent movements
    Route::get('/movements/recent', [InventoryMovementController::class, 'getRecentMovements'])
        ->middleware('throttle:60,1');
});
