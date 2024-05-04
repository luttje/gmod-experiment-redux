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
        // When the voice server sends transcribed chat logs to the API, they only include the steam_id of the speaker.
        // For that reason, we need to track other information of the speaker before the time of the chat log.
        Schema::create('player_infos', function (Blueprint $table) {
            $table->id();

            $table->string('steam_name'); // if anonymized, this is a hash of the steam_id
            $table->string('steam_id')->unique(); // if anonymized, this is a hash of the steam_id
            $table->string('character_name')->nullable();
            $table->bigInteger('character_id')->nullable()->index(); // can still be null if the player is not yet in-game
            $table->string('ip_address')->index(); // if anonymized, this is a hash of the ip_address
            $table->timestamp('anonymized_at')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('player_infos');
    }
};
