<?php

use Illuminate\Support\Facades\Route;

// Only keep the absolute basics
Route::get('/', function () {
    return response()->json(['message' => 'VitalVida API - Use /api/* endpoints']);
});
