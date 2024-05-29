<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Collection;

class Metric extends Model
{
    use HasFactory;

    protected $guarded = [];

    /**
     * Relationships
     */

    public function epoch()
    {
        return $this->belongsTo(Epoch::class);
    }

    public function characters()
    {
        return $this->belongsToMany(Character::class)
            ->using(CharacterMetric::class)
            ->orderByPivot('created_at', 'desc')
            ->orderByPivot('value', 'desc')
            ->withPivot(['value', 'created_at', 'updated_at']);
    }

    /**
     * Static helpers
     */

    /**
     * Sums the latest metrics for each character to get the overall leader
     */
    public static function getOverallScores(Collection $metrics)
    {
        $overallLeaders = $metrics->flatMap
            ->characters
            ->groupBy('id')
            ->map(function ($characters) {
                return [
                    'character' => $characters->first(),
                    'value' => $characters->sum('pivot.value'),
                ];
            })
            ->sortByDesc('value')
            ->values();

        return $overallLeaders;
    }

    /**
     * Gets the latest metric for each character
     */
    public static function withEagerRelations()
    {
        return Metric::with([
            'characters.player'
        ])->get();
    }
}
