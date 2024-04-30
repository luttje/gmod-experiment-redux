<?php

use App\Http\Controllers\LeaderboardController;
use Illuminate\Support\Facades\Route;

Route::redirect('/', '/leaderboards');

Route::get('/leaderboards/overall', [LeaderboardController::class, 'overall'])->name('leaderboards.overall');
Route::resource('leaderboards', LeaderboardController::class)->parameter('leaderboards', 'metric');
