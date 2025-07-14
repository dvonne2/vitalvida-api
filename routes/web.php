<?php

use Illuminate\Support\Facades\Route;

// Bypass all web middleware by using direct response
Route::get('/', function () {
    return response()->json(['message' => 'VitalVida API - Use /api/* endpoints']);
})->withoutMiddleware(['web']);

Route::get('/ping', function () {
    return response()->json(['status' => 'pong']);  
})->withoutMiddleware(['web']);

Route::get('/health-simple', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => date('c'),
        'app' => 'VitalVida'
    ]);
})->withoutMiddleware(['web']);
