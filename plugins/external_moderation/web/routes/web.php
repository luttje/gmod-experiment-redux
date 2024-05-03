<?php

use App\Http\Controllers\ChatLogController;
use App\Http\Controllers\ProfileController;
use App\Livewire\ChatLogModerationPage;
use App\Livewire\SanctionsOverviewPage;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
})->middleware('guest')
    ->name('home');

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::get('/chat-logs', ChatLogModerationPage::class)->name('chat-logs-moderation');
    Route::get('/sanctions', SanctionsOverviewPage::class)->name('sanctions-overview');
});

require __DIR__.'/auth.php';
