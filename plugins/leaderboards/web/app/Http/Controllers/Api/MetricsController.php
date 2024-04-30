<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alliance;
use App\Models\Character;
use App\Models\Epoch;
use App\Models\Metric;
use App\Models\Player;
use Illuminate\Http\Request;

class MetricsController extends Controller
{
    /**
     * At midnight the game server will submit all metrics data for the day.
     *
     * This will contain all not yet submitted metrics for players, characters and alliances this epoch.
     * All metrics data will also be submitted (e.g: name and description).
     *
     * This method will check if the epoch exists, if not it will create it.
     * It will do the same for players, characters and alliances.
     */
    public function submitMetrics(Request $request)
    {
        $data = $request->validate([
            'epoch' => 'required|array',
            'players' => 'required|array',
            'characters' => 'required|array',
            'alliances' => 'required|array',
            'metrics' => 'required|array',
            'character_metrics' => 'required|array',
        ]);

        $epoch = Epoch::firstOrCreate($data['epoch']);

        foreach ($data['players'] as $player) {
            Player::firstOrCreate($player);
        }

        foreach ($data['characters'] as $character) {
            $epoch->characters()->firstOrCreate($character);
        }

        foreach ($data['alliances'] as $alliance) {
            $epoch->alliances()->firstOrCreate($alliance);
        }

        foreach ($data['metrics'] as $metric) {
            $epoch->metrics()->firstOrCreate($metric);
        }

        foreach ($data['character_metrics'] as $characterMetric) {
            $character = Character::find($characterMetric['character_id']);
            $metric = Metric::find($characterMetric['metric_id']);

            $character->metrics()->attach($metric, [
                'value' => $characterMetric['value'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }

        return [
            'message' => 'Metrics submitted successfully',
        ];
    }

    /**
     * Get all character scores for a given epoch, grouped by metric.
     */
    public function getCharacterScores(Request $request, Epoch $epoch)
    {
        $epoch->load([
            'metrics',
            'characters.player',
        ]);

        $metricScores = $epoch->getMetricScoresArray();

        return [
            'data' => $metricScores,
            'related' => [
                'epoch' => [
                    'id' => $epoch->id,
                    'name' => $epoch->name,
                    'started_at' => $epoch->started_at,
                    'ends_at' => $epoch->ends_at,
                ],
                'metrics' => $epoch->metrics->mapWithKeys(function ($metric) {
                    return [$metric->id => $metric->only('id', 'name', 'description')];
                }),
                'characters' => $epoch->characters->mapWithKeys(function ($character) {
                    return [$character->id => $character->only('id', 'name')];
                }),
                'alliances' => $epoch->alliances->mapWithKeys(function ($alliance) {
                    return [$alliance->id => $alliance->only('id', 'name')];
                }),
                'players' => $epoch->characters->mapWithKeys(function ($character) {
                    return [$character->player->id => $character->player->only('id', 'name')];
                }),
            ]
        ];
    }
}
