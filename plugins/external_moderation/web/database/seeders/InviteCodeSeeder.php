<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class InviteCodeSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        \App\Models\InviteCode::create([
            'code' => 'TESTCODE1',
            'user_id' => 1,
        ]);

        \App\Models\InviteCode::create([
            'code' => 'TESTCODE2',
        ]);

        \App\Models\InviteCode::create([
            'code' => 'TESTCODE3',
        ]);
    }
}
