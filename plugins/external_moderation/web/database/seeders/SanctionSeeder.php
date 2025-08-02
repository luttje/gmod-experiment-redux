<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class SanctionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $sanctions = [
            [
                'steam_name' => 'Oldie',
                'steam_id' => '90071996842377218',
                'character_name' => 'Goldfinger',
                'character_id' => 3,
                'ip_address' => '192.168.1.2',
                'type' => 'mute',
                'reason' => 'Warning: Hate speech is not tolerated. This includes racism, sexism, homophobia, or discriminatory language. [1st Offense]',
                'expires_at' => now()->subDays(1),
                'issued_by' => null,
                'rule_id' => '1',
                'escalation_level' => 0,
                'chat_log_id' => null,
            ],
            [
                'steam_name' => 'Meanie',
                'steam_id' => '90071996842377217',
                'character_name' => 'Ernst Stavro Blofeld',
                'character_id' => 2,
                'ip_address' => '192.168.0.1',
                'type' => 'mute',
                'reason' => 'Warning: Hate speech is not tolerated. This includes racism, sexism, homophobia, or discriminatory language. [2nd Offense]',
                'expires_at' => now()->addMinutes(60),
                'issued_by' => null,
                'rule_id' => '1',
                'escalation_level' => 1,
                'chat_log_id' => null,
            ],
            [
                'steam_name' => 'Meanie',
                'steam_id' => '90071996842377217',
                'character_name' => 'Ernst Stavro Blofeld',
                'character_id' => 2,
                'ip_address' => '192.168.0.1',
                'type' => 'ban',
                'reason' => 'Warning: Harassment and personal attacks are prohibited. This includes targeting, bullying, or provoking other players. [1st Offense]',
                'expires_at' => now()->addDays(1),
                'issued_by' => 1,
                'rule_id' => '2',
                'escalation_level' => 0,
                'chat_log_id' => null,
            ],
        ];

        foreach ($sanctions as $sanction) {
            \App\Models\Sanction::create($sanction);
        }
    }
}
