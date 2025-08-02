<?php

use App\Http\Middleware\ApiAuth;
use Illuminate\Support\Facades\Route;

Route::middleware(ApiAuth::class)->group(function () {
    Route::post('/submit-chat-log', [\App\Http\Controllers\Api\ChatLogController::class, 'submitChatLog'])
        ->name('submit-chat-log');

    Route::post('/submit-voice-chat-log', [\App\Http\Controllers\Api\ChatLogController::class, 'submitVoiceChatLog'])
        ->name('submit-voice-chat-log');

    Route::post('/submit-player-info', [\App\Http\Controllers\Api\PlayerInfoController::class, 'submitPlayerInfo'])
        ->name('submit-player-info');

    Route::prefix('sanctions')->group(function () {
        Route::get('/', [App\Http\Controllers\Api\SanctionController::class, 'index']);
        // Route::get('/player/{steamId}', [App\Http\Controllers\Api\SanctionController::class, 'player']);
        // Route::get('/type/{type}', [App\Http\Controllers\Api\SanctionController::class, 'byType']);
        // Route::get('/check/{steamId}', [App\Http\Controllers\Api\SanctionController::class, 'check']);
    });
});
