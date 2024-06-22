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
     * Will pre-calculate the leaderboards for each metric the current epoch. Easily accessible will be:
     * - The leader for each metric
     * - The order of all characters for each metric
     * - The leader for the overall leaderboard
     * - The order of all characters for the overall leaderboard
     *
     * This will be done by calculating the sum of all metrics for each player, character and alliance.
     * The leaderboards will be stored in cache and will be used to display the leaderboards on the website.
     */
    public static function precacheLeaderboards()
    {
        $characterMetrics = CharacterMetric::with([
            'character',
            'character.player',
            'metric',
        ])->get();

        $overallScores = [];
        $metricScores = [];

        // Get the sum of all metrics for each character
        foreach ($characterMetrics as $characterMetric) {
            $characterId = $characterMetric->character_id;
            $metricId = $characterMetric->metric_id;
            $value = $characterMetric->value;

            // Add the value to the overall leaderboard
            if (!isset($overallScores[$characterId])) {
                $overallScores[$characterId] = 0;
            }

            $weight = 1; // TODO: Weigh the metrics based on what we find important
            $overallScores[$characterId] += $value * $weight;

            // Add the value to the metric leaderboard
            if (!isset($metricScores[$metricId])) {
                $metricScores[$metricId] = [];
            }

            if (!isset($metricScores[$metricId][$characterId])) {
                $metricScores[$metricId][$characterId] = 0;
            }

            $metricScores[$metricId][$characterId] += $value;
        }

        // Add any empty metrics to the metric leaderboard
        $metrics = Metric::with('epoch')->get();

        foreach ($metrics as $metric) {
            $metricId = $metric->id;

            if (!isset($metricScores[$metricId])) {
                $metricScores[$metricId] = [];
            }
        }

        $now = now();

        // Sort the scores for the overall and metric leaderboards, mapping
        // character and player data for easy access
        arsort($overallScores);

        foreach ($metricScores as $metricId => $scores) {
            arsort($scores);

            $characterScores = collect($scores);
            $leaderScore = $characterScores->first();
            $leaderId = $characterScores->keys()->first();

            if ($leaderScore) {
                $character = Character::with('player')->find($leaderId);
                $leader = [
                    'character' => $character->toArray(),
                    'player' => $character->player->toArray(),
                    'sum' => $leaderScore,
                ];
            } else {
                $leader = null;
            }

            $metricScores[$metricId] = [
                'id' => $metricId,
                'name' => Metric::find($metricId)->name,
                'updatedAt' => $now,
                'scores' => $characterScores->mapWithKeys(function ($value, $key) {
                    $character = Character::with('player')->find($key);
                    return [
                        $key => [
                            'character' => $character->toArray(),
                            'player' => $character->player->toArray(),
                            'sum' => $value,
                        ],
                    ];
                })->toArray(),
                'leader' => $leader,
            ];
        }

        $overallLeaderId = $overallScores ? key($overallScores) : null;
        $overallLeader = $overallLeaderId ? [
            'character' => Character::find($overallLeaderId)->toArray(),
            'player' => Character::find($overallLeaderId)->player->toArray(),
            'value' => $overallScores[$overallLeaderId],
        ] : null;

        $overallScores = collect($overallScores)->mapWithKeys(function ($value, $key) {
            $character = Character::with('player')->find($key);
            return [
                $key => [
                    'character' => $character->toArray(),
                    'player' => $character->player->toArray(),
                    'sum' => $value,
                ],
            ];
        })->toArray();

        // Store for quick access
        $overallScores['updatedAt'] = $now;
        $metricScores['updatedAt'] = $now;

        $epoch = $metrics->first()->epoch;

        cache()->forever('scores:' . $epoch->id, [
            'overallScores' => $overallScores,
            'metricScores' => $metricScores,
            'overallLeader' => $overallLeader,
        ]);
    }

    public static function leaderboardsFromCache(Epoch $epoch): array
    {
        return cache('scores:' . $epoch->id) ?? [
            'overallScores' => [],
            'metricScores' => [],
            'overallLeader' => null,
        ];
    }
}
