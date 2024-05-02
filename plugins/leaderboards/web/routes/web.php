<?php

use App\Http\Controllers\LeaderboardController;
use Illuminate\Support\Facades\Route;

Route::get('/', [LeaderboardController::class, 'index'])->name('leaderboards.index');

Route::get('/overall', [LeaderboardController::class, 'overall'])->name('leaderboards.overall');
Route::resource('/leaderboards', LeaderboardController::class)
    ->except(['index'])
    ->parameter('leaderboards', 'metric');
