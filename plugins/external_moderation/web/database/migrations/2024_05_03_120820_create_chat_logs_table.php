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
        Schema::create('chat_logs', function (Blueprint $table) {
            $table->id();

            $table->string('chat_type'); // voice, ic, ooc, etc.

            $table->string('steam_name'); // if anonymized, this is a hash of the steam_id
            $table->string('steam_id')->index(); // if anonymized, this is a hash of the steam_id
            $table->string('character_name')->nullable();
            $table->bigInteger('character_id')->nullable()->index();
            $table->string('ip_address')->index(); // if anonymized, this is a hash of the ip_address
            $table->timestamp('anonymized_at')->nullable();

            $table->string('voice_chat_path')->nullable(); // if this is a voice chat message, the path to the audio file
            $table->text('message')->nullable(); // will be null if it's a not yet transcribed voice chat message

            $table->timestamp('flagged_at')->nullable(); // whether the system has flagged this message as potentially problematic
            $table->string('flagged_reason')->nullable();

            $table->timestamp('moderated_at')->nullable();
            $table->foreignId('moderated_by')->nullable()->constrained('users');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('chat_logs');
    }
};
