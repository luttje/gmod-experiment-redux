<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlayerInfo extends Model
{
    use HasFactory;

    protected $fillable = [
        'steam_id',
        'steam_name',
        'character_id',
        'character_name',
        'ip_address',
    ];
}
