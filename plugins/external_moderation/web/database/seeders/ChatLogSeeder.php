<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class ChatLogSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $chatLogs = [
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Luttje',
                'steam_id' => '76561198002016569',
                'character_name' => 'James Bond',
                'character_id' => 1,
                'ip_address' => '127.0.0.1',
                'message' => 'Hello everyone!',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Meanie',
                'steam_id' => '90071996842377217',
                'character_name' => 'Ernst Stavro Blofeld',
                'character_id' => 2,
                'ip_address' => '192.168.0.1',
                'message' => 'Hello asshole!',
                'flagged_at' => now(),
                'flagged_reason' => 'Inappropriate language',
            ],
            [
                'chat_type' => 'ooc',
                'steam_name' => 'Luttje',
                'steam_id' => '76561198002016569',
                'character_name' => 'James Bond',
                'character_id' => 1,
                'ip_address' => '127.0.0.1',
                'message' => 'Wow, that was rude!',
            ],
            [
                'chat_type' => 'voice',
                'steam_name' => 'Meanie',
                'steam_id' => '90071996842377217',
                'character_name' => 'Ernst Stavro Blofeld',
                'character_id' => 2,
                'ip_address' => '192.168.0.1',
                'voice_chat_path' => '/srv/experiment-redux/plugins/external_moderation/voice-server/recordings/transcribed/000000000000000000000.wav', // TODO: Create audio file and have it be transcribed
            ],
        ];

        foreach ($chatLogs as $chatLog) {
            \App\Models\ChatLog::create($chatLog);
        }
    }
}
