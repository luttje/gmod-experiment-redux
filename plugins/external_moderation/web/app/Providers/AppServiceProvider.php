<?php

namespace App\Providers;

use App\Console\Commands\ProcessAiModerationCommand;
use App\Models\ChatLog;
use App\Observers\ChatLogObserver;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\Facades\Schedule;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        RateLimiter::for('strict', function (Request $request) {
            return Limit::perMinute(5);
        });

        // Register the ChatLog observer for automatic AI moderation
        ChatLog::observe(ChatLogObserver::class);

        // Process AI moderation every 2 minutes
        // Schedule::command(ProcessAiModerationCommand::class)
        //     ->everyTwoMinutes()
        //     ->withoutOverlapping()
        //     ->runInBackground();
    }
}
