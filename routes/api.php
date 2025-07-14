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

// Web-style routes that work in API context
Route::get('/root', function () {
    return response()->json(['message' => 'VitalVida API - Use /api/* endpoints']);
});

Route::get('/web-ping', function () {
    return response()->json(['status' => 'pong']);
});

Route::get('/web-health', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => date('c'),
        'app' => 'VitalVida'
    ]);
});
