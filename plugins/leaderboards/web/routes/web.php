<?php

use App\Http\Controllers\CharacterController;
use App\Http\Controllers\LeaderboardController;
use Illuminate\Support\Facades\Route;

Route::get('/', [LeaderboardController::class, 'index'])->name('leaderboards.index');
Route::get('/how-it-works', [LeaderboardController::class, 'howItWorks'])->name('leaderboards.how-it-works');

Route::get('/overall/{epoch?}', [LeaderboardController::class, 'overall'])->name('leaderboards.overall');
Route::get('/overall/historic/{epoch?}', [LeaderboardController::class, 'overall'])->name('leaderboards.overall-historic');
Route::get('/leaderboards/historic/{epoch?}', [LeaderboardController::class, 'index'])->name('leaderboards.index-historic');
Route::get('/leaderboards/historic/{metric}/{epoch?}', [LeaderboardController::class, 'show'])->name('leaderboards.show-historic');
Route::resource('/leaderboards', LeaderboardController::class)
    ->except(['index'])
    ->parameter('leaderboards', 'metric');

Route::get('/characters/{character}/claim-rewards', [CharacterController::class, 'claimRewards'])->name('characters.claim-rewards');
Route::post('/characters/{character}/claim-rewards', [CharacterController::class, 'confirmClaimRewards'])->name('characters.claim-rewards');

Route::resource('/characters', CharacterController::class)
    ->only(['index'])
    ->middleware('auth');

Route::get('/login', function () {
    return redirect()->route('leaderboards.index');
})->name('login');

require __DIR__.'/auth.php';
