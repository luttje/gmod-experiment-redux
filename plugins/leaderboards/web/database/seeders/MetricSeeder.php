<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class MetricSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $metrics = [
            [
                'epoch_id' => 1,
                'name' => 'Bolts Generated',
                'description' => 'The number of bolts a character has generated.',
            ],
            [
                'epoch_id' => 1,
                'name' => 'Successfully Defended',
                'description' => 'The amount of successful defenses a character has made against an attack.',
            ],
            [
                'epoch_id' => 1,
                'name' => 'Healing Done',
                'description' => 'The amount of healing a character has done.',
            ],
            [
                'epoch_id' => 1,
                'name' => 'Healing Received',
                'description' => 'The amount of healing a character has received.',
            ],
            [
                'epoch_id' => 1,
                'name' => 'Bolts Spent',
                'description' => 'The amount of bolts a character has spent.',
            ],
        ];

        DatabaseSeeder::addTimestamps($metrics);
        \App\Models\Metric::insert($metrics);

        /**
         * Add metrics for some characters
         */
        $characterMetrics = [
            [
                'character_id' => 1,
                'metric_id' => 1,
                'alliance_id' => null,
                'value' => 100,
            ],
            [
                'character_id' => 1,
                'metric_id' => 2,
                'alliance_id' => null,
                'value' => 50,
            ],
            [
                'character_id' => 1,
                'metric_id' => 3,
                'alliance_id' => null,
                'value' => 25,
            ],
            [
                'character_id' => 1,
                'metric_id' => 4,
                'alliance_id' => null,
                'value' => 10,
            ],
            [
                'character_id' => 1,
                'metric_id' => 5,
                'alliance_id' => null,
                'value' => 75,
            ],
            [
                'character_id' => 2,
                'metric_id' => 1,
                'alliance_id' => 1,
                'value' => 200,
            ],
            [
                'character_id' => 2,
                'metric_id' => 2,
                'alliance_id' => 1,
                'value' => 100,
            ],
            [
                'character_id' => 2,
                'metric_id' => 3,
                'alliance_id' => 1,
                'value' => 50,
            ],
            [
                'character_id' => 2,
                'metric_id' => 4,
                'alliance_id' => 1,
                'value' => 20,
            ],
            [
                'character_id' => 2,
                'metric_id' => 5,
                'alliance_id' => 1,
                'value' => 150,
            ],
            [
                'character_id' => 3,
                'metric_id' => 1,
                'alliance_id' => 1,
                'value' => 300,
            ],
            [
                'character_id' => 3,
                'metric_id' => 2,
                'alliance_id' => 1,
                'value' => 150,
            ],
            [
                'character_id' => 3,
                'metric_id' => 3,
                'alliance_id' => 1,
                'value' => 75,
            ],
            [
                'character_id' => 3,
                'metric_id' => 4,
                'alliance_id' => 1,
                'value' => 30,
            ],
            [
                'character_id' => 3,
                'metric_id' => 5,
                'alliance_id' => 1,
                'value' => 225,
            ],
        ];

        $metrics = \App\Models\Metric::all();

        for ($i = 4; $i <= 100; $i++) {
            foreach ($metrics as $metric) {
                $characterMetrics[] = [
                    'character_id' => $i,
                    'metric_id' => $metric->id,
                    'alliance_id' => null,
                    'value' => fake()->numberBetween(1, 100)
                ];
            }
        }

        DatabaseSeeder::addTimestamps($characterMetrics);
        \App\Models\CharacterMetric::insert($characterMetrics);
    }
}
