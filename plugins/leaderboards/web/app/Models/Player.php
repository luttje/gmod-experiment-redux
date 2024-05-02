<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Player extends Model
{
    use HasFactory;

    protected $guarded = [];

    /**
     * Relationships
     */

    public function characters()
    {
        return $this->hasMany(Character::class, 'steam_id', 'steam_id');
    }
}
