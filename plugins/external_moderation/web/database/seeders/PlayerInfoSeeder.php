<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class PlayerInfoSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\PlayerInfo::create([
            'steam_name' => 'Oldie',
            'steam_id' => '90071996842377218',
            'character_name' => 'Goldfinger',
            'character_id' => 3,
            'ip_address' => '192.168.1.2',
        ]);
    }
}
