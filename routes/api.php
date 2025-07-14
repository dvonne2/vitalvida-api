<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Health check routes
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'database' => 'connected', // We'll make this dynamic later
        'app' => 'VitalVida',
        'env' => config('app.env')
    ]);
});

// Simple ping route
Route::get('/ping', function () {
    return response()->json(['status' => 'pong']);
});

// Auth routes (placeholder - will add proper controller later)
Route::post('/login', function (Request $request) {
    return response()->json([
        'status' => 'success',
        'message' => 'Login endpoint working',
        'data' => $request->all()
    ]);
});

// User route
Route::get('/user', function () {
    return response()->json([
        'status' => 'success',
        'message' => 'User endpoint working'
    ]);
});
