<?php

use Illuminate\Support\Facades\Route;

Route::get('/', fn () => response()->json([
    'message' => 'Welcome to the VitalVida API',
    'documentation' => 'Use /api/* endpoints',
    'endpoints' => [
        'health' => '/api/health',
        'ping' => '/api/web-ping',
        'login' => '/api/login'
    ]
]));
