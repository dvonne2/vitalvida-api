<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

// AI Command Room Routes
Route::prefix('ai-command-room')->group(function () {
    Route::get('/', [App\Http\Controllers\AICommandRoomController::class, 'dashboard'])->name('ai-command-room.dashboard');
    Route::get('/metrics', [App\Http\Controllers\AICommandRoomController::class, 'getRealTimeMetrics'])->name('ai-command-room.metrics');
    Route::post('/trigger-action', [App\Http\Controllers\AICommandRoomController::class, 'triggerAIAction'])->name('ai-command-room.trigger-action');
    Route::get('/creatives/top', [App\Http\Controllers\AICommandRoomController::class, 'getTopPerformingCreatives'])->name('ai-command-room.top-creatives');
    Route::get('/ai-actions/recent', [App\Http\Controllers\AICommandRoomController::class, 'getRecentAIActions'])->name('ai-command-room.recent-actions');
});

// Monitoring routes (public, no authentication required)
Route::group(['prefix' => 'api/monitoring', 'middleware' => ['security.headers']], function () {
    Route::get('/health', [App\Http\Controllers\Api\MonitoringController::class, 'health']);
    Route::get('/performance', [App\Http\Controllers\Api\MonitoringController::class, 'performance']);
    Route::get('/api-metrics', [App\Http\Controllers\Api\MonitoringController::class, 'apiMetrics']);
    Route::get('/database-metrics', [App\Http\Controllers\Api\MonitoringController::class, 'databaseMetrics']);
    Route::get('/cache-metrics', [App\Http\Controllers\Api\MonitoringController::class, 'cacheMetrics']);
    Route::get('/alerts', [App\Http\Controllers\Api\MonitoringController::class, 'alerts']);
    Route::get('/real-time-status', [App\Http\Controllers\Api\MonitoringController::class, 'realTimeStatus']);
});
