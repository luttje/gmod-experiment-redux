<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Epoch extends Model
{
    use HasFactory;

    protected $guarded = [];

    public function getMetricScoresArray()
    {
        return $this->metrics()
            ->with([
                'characters.player',
            ])
            ->get()
            ->map(function ($metric) {
                return [
                    'metric_id' => $metric->id,
                    // Only get the last score value for each character
                    'scores' => $metric->characters->groupBy('id')
                        ->map(function ($characters) {
                            $character = $characters->first();
                            return [
                                'character_id' => $character->id,
                                'steam_id' => $character->player->steam_id,
                                'value' => $character->pivot->value,
                                'timestamp' => $character->pivot->created_at,
                            ];
                        })
                        ->sortByDesc('value')
                        ->values(),
                ];
            });
    }

    /**
     * Relationships
     */

    public function characters()
    {
        return $this->hasMany(Character::class);
    }

    public function metrics()
    {
        return $this->hasMany(Metric::class);
    }

    public function alliances()
    {
        return $this->hasMany(Alliance::class);
    }
}