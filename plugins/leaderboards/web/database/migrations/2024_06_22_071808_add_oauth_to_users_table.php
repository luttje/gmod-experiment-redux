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
        Schema::table('users', function (Blueprint $table) {
            $table->string('discord_id')->nullable()->unique();
            $table->string('discord_nickname')->nullable();
            $table->string('discord_name')->nullable();
            $table->string('discord_email')->nullable();
            $table->string('discord_avatar')->nullable();

            $table->string('discord_token')->nullable();
            $table->string('discord_refresh_token')->nullable();

            $table->string('steam_id')->nullable()->unique();
            $table->string('steam_nickname')->nullable();
            $table->string('steam_avatar')->nullable();

            $table->string('steam_token')->nullable();
            $table->string('steam_refresh_token')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('discord_id');
            $table->dropColumn('discord_nickname');
            $table->dropColumn('discord_name');
            $table->dropColumn('discord_email');
            $table->dropColumn('discord_avatar');

            $table->dropColumn('discord_token');
            $table->dropColumn('discord_refresh_token');

            $table->dropColumn('steam_id');
            $table->dropColumn('steam_nickname');
            $table->dropColumn('steam_avatar');

            $table->dropColumn('steam_token');
            $table->dropColumn('steam_refresh_token');
        });
    }
};
