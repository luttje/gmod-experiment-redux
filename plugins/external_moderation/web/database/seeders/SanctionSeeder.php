<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
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
                'reason' => 'Inappropriate language',
                'expires_at' => now()->subDays(1),
                'issued_by' => 1,
            ],
            [
                'steam_name' => 'Meanie',
                'steam_id' => '90071996842377217',
                'character_name' => 'Ernst Stavro Blofeld',
                'character_id' => 2,
                'ip_address' => '192.168.0.1',
                'type' => 'mute',
                'reason' => 'Inappropriate language',
                'expires_at' => now()->addMinutes(60),
                'issued_by' => 1,
            ],
        ];

        foreach ($sanctions as $sanction) {
            \App\Models\Sanction::create($sanction);
        }
    }
}
