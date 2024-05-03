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
            $table->string('character_name');
            $table->bigInteger('character_id')->nullable()->index();
            $table->string('ip_address')->index(); // if anonymized, this is a hash of the ip_address
            $table->timestamp('anonymized_at')->nullable();

            $table->string('type'); // mute, kick, ban, etc.
            $table->text('reason')->nullable();
            $table->timestamp('expires_at')->nullable();

            $table->foreignId('issued_by')->nullable()->constrained('users');

            $table->timestamps();
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
