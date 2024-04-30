<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public static function addTimestamps(array &$data): void
    {
        $now = now();

        foreach ($data as &$row) {
            $row['created_at'] = $now;
            $row['updated_at'] = $now;
        }
    }

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        User::factory()->create([
            'name' => 'Admin User',
            'email' => 'admin@example.com',
        ]);

        $this->call([
            EpochSeeder::class,
            PlayerSeeder::class,
            CharacterSeeder::class,
            AllianceSeeder::class,
            MetricSeeder::class,
        ]);
    }
}
