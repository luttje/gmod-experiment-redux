<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class PlayerSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $players = [
            [
                'steam_name' => 'Luttje',
                'steam_id' => '76561198002016569',
                'opt_out_leaderboard_at' => null,
            ],
            [
                'steam_name' => 'ejttul',
                'steam_id' => '90071996842377216',
                'opt_out_leaderboard_at' => null,
            ],
            [
                'steam_name' => 'ttulje',
                'steam_id' => '90071996842377217',
                'opt_out_leaderboard_at' => null,
            ],
        ];

        for ($i = 1; $i <= 100; $i++) {
            $players[] = [
                'steam_name' => fake()->name,
                'steam_id' => '90071996842377' . (217 + $i),
                'opt_out_leaderboard_at' => null,
            ];
        }

        DatabaseSeeder::addTimestamps($players);
        \App\Models\Player::insert($players);
    }
}
