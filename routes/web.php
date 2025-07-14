<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// Simple health check without database dependency
Route::get('/health-simple', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => now()->toIso8601String(),
        'app' => 'VitalVida API'
    ]);
});

// Debug route to check environment variables
Route::get('/debug-env', function () {
    return response()->json([
        'APP_KEY' => env('APP_KEY') ? 'SET' : 'NOT SET',
        'APP_ENV' => env('APP_ENV'),
        'APP_DEBUG' => env('APP_DEBUG'),
        'all_env' => array_keys($_ENV)
    ]);
});

// Simple health check without database
Route::get('/ping', function () {
    return response()->json(['status' => 'pong']);
});
Route::get('/ping', function () { return response()->json(['status' => 'pong']); });
