<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Alliance;
use App\Models\Character;
use App\Models\CharacterMetric;
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
        $this->fixRequest($request);

        $data = $request->validate([
            'epoch' => 'required|array:name,ends_at,started_at',
            'players' => 'required|array',
            'characters' => 'required|array',
            'alliances' => 'present|array',
            'metrics' => 'present|array',
            'character_metrics' => 'present|array',
        ]);

        $epoch = Epoch::firstOrCreate($data['epoch']);

        foreach ($data['players'] as $player) {
            Player::updateOrCreate([
                'steam_id' => $player['steam_id'],
            ], $player);
        }

        foreach ($data['characters'] as $character) {
            $epoch->characters()->updateOrCreate([
                'id' => $character['id'],
            ], [
                ...$character,
                'epoch_id' => $epoch->id,
            ]);
        }

        foreach ($data['alliances'] as $alliance) {
            $epoch->alliances()->updateOrCreate([
                'id' => $alliance['id'],
            ], [
                ...$alliance,
                'epoch_id' => $epoch->id,
            ]);
        }

        foreach ($data['metrics'] as $metric) {
            $epoch->metrics()->firstOrCreate($metric);
        }

        $currentTimestamp = now();
        $metrics = $data['character_metrics'];

        $alliances = Alliance::pluck('id');

        foreach ($metrics as &$metric) {
            function metricValueOrNull($key)
            {
                return isset($metric[$key]) ? $metric[$key] : null;
            }

            // Make sure every metric has the same columns
            $metric['character_id'] = metricValueOrNull('character_id');

            // A character may not have an alliance, in which case this wont be set
            $metric['alliance_id'] = metricValueOrNull('alliance_id');

            // The alliance may not exist anymore if it was removed
            // TODO: Leave the alliance? Remove the foreign keys on client? I dunno yet.
            if ($metric['alliance_id'] !== null) {
                $metric['alliance_id'] = $alliances->contains($metric['alliance_id']) ? $metric['alliance_id'] : null;
            }

            $metric['metric_id'] = metricValueOrNull('metric_id');
            $metric['value'] = metricValueOrNull('value');

            $metric['created_at'] = $currentTimestamp;
            $metric['updated_at'] = $currentTimestamp;
        }

        CharacterMetric::upsert(
            $metrics,
            uniqueBy: ['character_id', 'metric_id'],
            update: ['value']
        );

        return [
            'message' => 'Metrics submitted successfully',
        ];
    }
}
