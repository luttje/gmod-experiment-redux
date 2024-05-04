<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        if (! app()->isProduction()) {
            User::factory()->create([
                'name' => 'Test Admin',
                'email' => 'admin@example.com',
            ]);

            $this->call([
                InviteCodeSeeder::class,
                ChatLogSeeder::class,
                SanctionSeeder::class,
                PlayerInfoSeeder::class,
            ]);
        }
    }
}
