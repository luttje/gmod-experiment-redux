<?php

use App\Http\Controllers\ChatLogController;
use App\Http\Controllers\ProfileController;
use App\Livewire\ChatLogModerationPage;
use App\Livewire\SanctionsOverviewPage;
use App\Models\ChatLog;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
})->middleware('guest')
    ->name('home');

Route::middleware(['auth', 'verified'])->group(function () {
    Route::get('/dashboard', function () {
        return view('dashboard');
    })->name('dashboard');

    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');

    Route::get('/chat-logs', ChatLogModerationPage::class)->name('chat-logs-moderation');
    Route::get('/sanctions', SanctionsOverviewPage::class)->name('sanctions-overview');

    // Streams the given audio file to the browser
    Route::get('/audio/{chatLog}', function(ChatLog $chatLog) {
        $voicePath = realpath($chatLog->voice_chat_path);

        if (!$voicePath) {
            abort(404);
        }

        return response()->stream(function () use ($voicePath) {
            $stream = fopen($voicePath, 'r');

            while (!feof($stream)) {
                echo fread($stream, 1024);
            }

            fclose($stream);
        }, 200, [
            'Content-Type' => 'audio/wav',
            'Content-Disposition' => 'inline; filename="voice_chat.wav"',
        ]);
    })->name('play-audio');
});

require __DIR__.'/auth.php';
