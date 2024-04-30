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
        Schema::create('alliance_character', function (Blueprint $table) {
            $table->id();

            $table->foreignId('character_id')->constrained()->onDelete('cascade');
            $table->foreignId('alliance_id')->constrained()->onDelete('cascade')->nullable();

            $table->string('rank');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('alliance_character');
    }
};
