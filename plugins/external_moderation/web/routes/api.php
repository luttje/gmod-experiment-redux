<?php

use App\Http\Middleware\ApiAuth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware(ApiAuth::class)->group(function () {
    Route::post('/submit-chat-log', [\App\Http\Controllers\Api\ChatLogController::class, 'submitChatLog'])
       ->name('submit-chat-log');

    Route::post('/submit-voice-chat-log', [\App\Http\Controllers\Api\ChatLogController::class, 'submitVoiceChatLog'])
       ->name('submit-voice-chat-log');

    Route::post('/submit-player-info', [\App\Http\Controllers\Api\PlayerInfoController::class, 'submitPlayerInfo'])
       ->name('submit-player-info');
});
