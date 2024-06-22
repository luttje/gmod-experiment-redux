<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Character extends Model
{
    use HasFactory;

    protected $guarded = [];

    /**
     * Relationships
     */

    public function characterRewards()
    {
        return $this->hasMany(CharacterReward::class)
            ->with('character');
    }

    public function player()
    {
        return $this->belongsTo(Player::class, 'steam_id', 'steam_id');
    }

    public function epoch()
    {
        return $this->belongsTo(Epoch::class);
    }

    public function alliances()
    {
        return $this->belongsToMany(Alliance::class)
            ->using(AllianceCharacter::class)
            ->orderByPivot('created_at', 'desc')
            ->withPivot(['rank', 'created_at', 'updated_at']);
    }

    public function metrics()
    {
        return $this->belongsToMany(Metric::class)
            ->using(CharacterMetric::class)
            ->orderByPivot('created_at', 'desc')
            ->withPivot(['value', 'created_at', 'updated_at']);
    }
}
