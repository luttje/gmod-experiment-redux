<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    'discord' => [
        'client_id' => env('DISCORD_CLIENT_ID'),
        'client_secret' => env('DISCORD_CLIENT_SECRET'),
        'redirect' => env('DISCORD_REDIRECT_URI'),
        'guild_id' => env('DISCORD_GUILD_ID'),
        'bot_token' => env('DISCORD_BOT_TOKEN'),

        'allow_gif_avatars' => (bool) env('DISCORD_AVATAR_GIF', false),
        'avatar_default_extension' => env('DISCORD_EXTENSION_DEFAULT', 'png'), // only pick from jpg, png, webp
    ],

    'steam' => [
        'client_id' => null,
        'client_secret' => env('STEAM_CLIENT_SECRET'),
        'redirect' => env('STEAM_REDIRECT_URI'),
        'allowed_hosts' => [
            env('STEAM_ALLOWED_LOCAL_HOST'),
        ]
    ],
];
