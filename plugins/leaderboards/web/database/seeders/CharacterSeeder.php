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
                'player_id' => 1,
                'epoch_id' => 1,
            ],
            [
                'name' => 'Doland Sitar',
                'player_id' => 2,
                'epoch_id' => 1,
            ],
            [
                'name' => 'Sally Ipsum',
                'player_id' => 3,
                'epoch_id' => 1,
            ],
        ];

        for ($i = 1; $i <= 100; $i++) {
            $characters[] = [
                'name' => fake()->name,
                'player_id' => $i,
                'epoch_id' => 1,
            ];
        }

        DatabaseSeeder::addTimestamps($characters);
        \App\Models\Character::insert($characters);
    }
}
