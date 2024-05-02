<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class CharacterSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $characters = [
            [
                'name' => 'Lorraine Ipsum',
                'steam_id' => '76561198002016569',
                'epoch_id' => 1,
            ],
            [
                'name' => 'Doland Sitar',
                'steam_id' => '90071996842377216',
                'epoch_id' => 1,
            ],
            [
                'name' => 'Sally Ipsum',
                'steam_id' => '90071996842377217',
                'epoch_id' => 1,
            ],
        ];

        $steam_ids = \App\Models\Player::pluck('steam_id')->toArray();

        for ($i = 1; $i <= 100; $i++) {
            $characters[] = [
                'name' => fake()->name,
                'steam_id' => $steam_ids[array_rand($steam_ids)],
                'epoch_id' => 1,
            ];
        }

        DatabaseSeeder::addTimestamps($characters);
        \App\Models\Character::insert($characters);
    }
}
