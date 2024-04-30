<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

/**
 * Api routes to submit metrics data for the leaderboard
 */
Route::post('/submit-metrics', [\App\Http\Controllers\Api\MetricsController::class, 'submitMetrics'])->name('submit-metrics');

Route::get('/get-character-scores/{epoch}', [\App\Http\Controllers\Api\MetricsController::class, 'getCharacterScores'])->name('get-character-scores');
