<?php

use App\Http\Middleware\ApiAuth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/**
 * Api routes to submit metrics data for the leaderboard
 */
Route::middleware(ApiAuth::class)->group(function () {
    Route::post('/submit-metrics', [\App\Http\Controllers\Api\MetricsController::class, 'submitMetrics'])
        ->name('submit-metrics');
});
