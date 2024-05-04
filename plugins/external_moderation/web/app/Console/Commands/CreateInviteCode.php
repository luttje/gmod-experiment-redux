<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class CreateInviteCode extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'app:create-invite-code';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Create an invite code for moderators to get access to the app.';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        // Ensure creating a unique code
        $inviteCode = null;

        do {
            $inviteCode = \Illuminate\Support\Str::random(32);
        } while (\App\Models\InviteCode::where('code', $inviteCode)->exists());

        \App\Models\InviteCode::create([
            'code' => $inviteCode,
        ]);

        $this->info("Invite code created: $inviteCode");

        return 0;
    }
}
