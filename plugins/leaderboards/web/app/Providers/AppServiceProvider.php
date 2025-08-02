<?php

namespace App\Providers;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Event;
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
        Model::preventLazyLoading(true);

        Event::listen(function (\SocialiteProviders\Manager\SocialiteWasCalled $event) {
            $event->extendSocialite('discord', \SocialiteProviders\Discord\Provider::class);
            $event->extendSocialite('steam', \SocialiteProviders\Steam\Provider::class);
        });

        $isInGame = request()->get('in-game', false);

        if ($isInGame) {
            // Store it in a cookie too, so links in this page will also be in-game
            cookie()->queue(cookie('in-game', true, 60 * 24 * 30)); // 30 days
        } elseif (! empty(request()->cookie('in-game'))) {
            // If the cookie is set, we assume the user is in-game
            $isInGame = true;
        }

        view()->share('isInGame', $isInGame);
    }
}
