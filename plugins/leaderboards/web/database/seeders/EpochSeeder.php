<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class EpochSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $epochs = [
            [
                'name' => 'The first Experiment',
                'started_at' => '2024-04-01 12:00:00',
                'ends_at' => '2024-04-30 12:00:00',
            ],
            [
                'name' => 'Second Epoch',
                'started_at' => '2024-05-1 12:00:00',
                'ends_at' => '2024-05-31 12:00:00',
            ],
            [
                'name' => 'Third Epoch',
                'started_at' => '2024-06-1 12:00:00',
                'ends_at' => '2024-06-30 12:00:00',
            ],
        ];

        DatabaseSeeder::addTimestamps($epochs);
        \App\Models\Epoch::insert($epochs);
    }
}
