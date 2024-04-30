<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class AllianceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $alliances = [
            [
                'name' => 'Legion',
                'epoch_id' => 1,
            ],
        ];

        DatabaseSeeder::addTimestamps($alliances);
        \App\Models\Alliance::insert($alliances);

        /**
         * Attach some characters to the alliance.
         */
        $allianceCharacter = [
            [
                'character_id' => 2,
                'alliance_id' => 1,
                'rank' => 'Major',
            ],
            [
                'character_id' => 3,
                'alliance_id' => 1,
                'rank' => 'Private',
            ],
        ];

        DatabaseSeeder::addTimestamps($allianceCharacter);
        \App\Models\AllianceCharacter::insert($allianceCharacter);
    }
}
