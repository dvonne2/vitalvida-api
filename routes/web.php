<?php

use Illuminate\Support\Facades\Route;

// Super minimal routes to avoid any conflicts
Route::get('/ping', function () {
    return response()->json(['status' => 'pong']);
});

Route::get('/health-simple', function () {
    return response()->json([
        'status' => 'ok',
        'timestamp' => date('c'),
        'app' => 'VitalVida'
    ]);
});

// Keep root route simple
Route::get('/', function () {
    return response()->json(['message' => 'VitalVida API']);
});
