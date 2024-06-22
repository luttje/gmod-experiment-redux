<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Http;

class Discord
{
    protected static string $apiUrl = 'https://discord.com/api/v10';

    protected static function getConfig(): array
    {
        return [
            'client_id' => config('services.discord.client_id'),
            'client_secret' => config('services.discord.client_secret'),
            'guild_id' => config('services.discord.guild_id'),
            'bot_token' => config('services.discord.bot_token'),
        ];
    }

    protected static function getHeaders(): array
    {
        $config = static::getConfig();

        return [
            'User-Agent' => 'DiscordBot (' . $config['client_id'] . ', 1.0)',
            'Authorization' => 'Bot ' . $config['bot_token'],
            'Accept' => 'application/json',
        ];
    }

    protected static function getRequest(string $url): array
    {
        return Http::withHeaders(static::getHeaders())->get(static::$apiUrl . $url)->json();
    }

    protected static function postRequest(string $url, array $data = []): array|null
    {
        return Http::withHeaders(static::getHeaders())->post(static::$apiUrl . $url, $data)->json();
    }

    protected static function putRequest(string $url, array $data = []): array|null
    {
        return Http::withHeaders(static::getHeaders())->put(static::$apiUrl . $url, $data)->json();
    }

    public static function getRole(string $roleName): array|null
    {
        $config = static::getConfig();

        $response = static::getRequest('/guilds/' . $config['guild_id'] . '/roles');

        return collect($response)->firstWhere('name', $roleName);
    }

    public static function addRole(string $roleName): array
    {
        $config = static::getConfig();

        $response = static::postRequest('/guilds/' . $config['guild_id'] . '/roles', [
            'name' => $roleName,
            // Display the role separately from other roles
            'hoist' => true,
        ]);

        return $response;
    }

    public static function setRoleForMember(string $discordUserId, string $roleName): void
    {
        $role = static::getRole($roleName);

        if (!$role) {
            $role = static::addRole($roleName);
        }

        $config = static::getConfig();

        static::putRequest('/guilds/' . $config['guild_id'] . '/members/' . $discordUserId . '/roles/' . $role['id']);
    }
}
