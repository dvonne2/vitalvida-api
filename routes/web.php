<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'message' => 'Welcome to the VitalVida API',
        'status' => 'use /api/* for all endpoints',
    ]);
});
