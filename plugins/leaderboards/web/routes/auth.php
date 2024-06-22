<?php

use Illuminate\Support\Facades\Route;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Laravel\Socialite\Facades\Socialite;

/*
    Discord OAuth
*/
Route::get('/auth/discord/redirect', function () {
    return Socialite::driver('discord')->redirect();
})->name('auth.discord');

Route::get('/auth/discord/callback', function () {
    $oauthUser = Socialite::driver('discord')->user();

    // If we're already logged in, we don't need to create a new user,
    // but just connect the account to the existing user
    if (user() !== null) {
        $user = user();
        $user->update([
            'discord_id' => $oauthUser->id,
            'discord_nickname' => $oauthUser->nickname,
            'discord_name' => $oauthUser->name,
            'discord_email' => $oauthUser->email,
            'discord_avatar' => $oauthUser->avatar,

            'discord_token' => $oauthUser->token,
            'discord_refresh_token' => $oauthUser->refreshToken,
        ]);

        return redirect('/');
    }

    $user = User::updateOrCreate([
        'discord_id' => $oauthUser->id,
    ], [
        'discord_nickname' => $oauthUser->nickname,
        'discord_name' => $oauthUser->name,
        'discord_email' => $oauthUser->email,
        'discord_avatar' => $oauthUser->avatar,

        'discord_token' => $oauthUser->token,
        'discord_refresh_token' => $oauthUser->refreshToken,
    ]);

    Auth::login($user);

    return redirect('/');
});

/*
    Steam OAuth
*/
Route::get('/auth/steam/redirect', function () {
    return Socialite::driver('steam')->redirect();
})->name('auth.steam');

Route::get('/auth/steam/callback', function () {
    $oauthUser = Socialite::driver('steam')->user();

    // If we're already logged in, we don't need to create a new user,
    // but just connect the account to the existing user
    if (user() !== null) {
        $user = user();
        $user->update([
            'steam_id' => $oauthUser->id,
            'steam_nickname' => $oauthUser->nickname,
            'steam_avatar' => $oauthUser->avatar,

            'steam_token' => $oauthUser->token,
            'steam_refresh_token' => $oauthUser->refreshToken,
        ]);

        return redirect('/');
    }

    $user = User::updateOrCreate([
        'steam_id' => $oauthUser->id,
    ], [
        'steam_nickname' => $oauthUser->nickname,
        'steam_avatar' => $oauthUser->avatar,

        'steam_token' => $oauthUser->token,
        'steam_refresh_token' => $oauthUser->refreshToken,
    ]);

    Auth::login($user);

    return redirect('/');
});
