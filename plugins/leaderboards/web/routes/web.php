<?php

use App\Http\Controllers\LeaderboardController;
use Illuminate\Support\Facades\Route;

Route::get('/', [LeaderboardController::class, 'index'])->name('leaderboards.index');

Route::get('/overall/{epoch?}', [LeaderboardController::class, 'overall'])->name('leaderboards.overall');
Route::get('/overall/historic/{epoch?}', [LeaderboardController::class, 'overall'])->name('leaderboards.overall-historic');
Route::get('/leaderboards/historic/{epoch?}', [LeaderboardController::class, 'index'])->name('leaderboards.index-historic');
Route::get('/leaderboards/historic/{metric}/{epoch?}', [LeaderboardController::class, 'show'])->name('leaderboards.show-historic');
Route::resource('/leaderboards', LeaderboardController::class)
    ->except(['index'])
    ->parameter('leaderboards', 'metric');

require __DIR__.'/auth.php';
