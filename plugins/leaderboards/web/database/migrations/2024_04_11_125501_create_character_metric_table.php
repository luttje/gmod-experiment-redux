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
        Schema::create('character_metric', function (Blueprint $table) {
            $table->id();

            $table->foreignId('character_id')->constrained()->onDelete('cascade');
            $table->foreignId('metric_id')->constrained()->onDelete('cascade');
            $table->foreignId('alliance_id')->nullable()->constrained()->onDelete('cascade');

            $table->bigInteger('value');

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('character_metric');
    }
};
