<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('sanctions', function (Blueprint $table) {
            $table->id();

            $table->string('steam_name'); // if anonymized, this is a hash of the steam_id
            $table->string('steam_id')->index(); // if anonymized, this is a hash of the steam_id
            $table->string('character_name')->nullable();
            $table->bigInteger('character_id')->nullable()->index();
            $table->string('ip_address')->index(); // if anonymized, this is a hash of the ip_address
            $table->timestamp('anonymized_at')->nullable();

            $table->string('type'); // mute, kick, ban, etc.
            $table->text('reason')->nullable();
            $table->timestamp('expires_at')->nullable();

            $table->foreignId('issued_by')->nullable()->constrained('users');

            // Used to track earlier violations or rule breaking
            $table->string('rule_id')->nullable()->index(); // e.g., '1', '2', etc.
            $table->integer('escalation_level')->nullable(); // 0, 1, 2, etc.
            $table->foreignId('chat_log_id')->nullable()->constrained('chat_logs');

            $table->timestamps();

            // Index for escalation lookups
            $table->index(['steam_id', 'rule_id', 'created_at'], 'idx_player_rule_history');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sanctions');
    }
};
