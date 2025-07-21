<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// MINIMAL TEST - If this doesn't work, it's 100% Railway issue
Route::get('/minimal-test', function () {
    return response()->json(['message' => 'Railway deployment working!']);
});

// Keep ONE existing route that works
Route::get('/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now(),
        'database' => 'connected',
        'app' => 'VitalVida',
        'env' => config('app.env')
    ]);
});
