<?php

// Web routes intentionally kept minimal due to Railway compatibility issues
// All API functionality is available at /api/* endpoints

use Illuminate\Support\Facades\Route;

// Optional: Keep only a simple redirect to API documentation
Route::get('/', function () {
    return response()->json([
        'message' => 'VitalVida API',
        'documentation' => 'Use /api/* endpoints',
        'endpoints' => [
            'health' => '/api/health',
            'ping' => '/api/web-ping',
            'login' => '/api/login'
        ]
    ]);
});
