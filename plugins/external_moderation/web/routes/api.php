<?php

use App\Http\Middleware\ApiAuth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware(ApiAuth::class)->group(function () {
    // TODO: Route::post('/submit-chat-log', [\App\Http\Controllers\Api\ChatLogController::class, 'submitChatLog'])
    // TODO:    ->name('submit-chat-log');
});
