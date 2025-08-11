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
        if (app()->isProduction()) {
            // In production, we don't seed the database.
            return;
        }

        User::factory()->create([
            // Our user migrations don't have these anymore:
            // 'name' => 'Admin User',
            // 'email' => 'admin@example.com',
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
