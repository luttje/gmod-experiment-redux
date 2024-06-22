<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CharacterReward extends Model
{
    use HasFactory;

    protected $guarded = [];

    protected $casts = [
        'data' => 'array',
    ];

    /**
     * Relationships
     */
    public function character()
    {
        return $this->belongsTo(Character::class);
    }

    /**
     * Attributes
     */
    public function getRewardAttribute()
    {
        return new $this->reward_class($this->character, $this->data);
    }
}
