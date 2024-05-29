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

        foreach ($data['metrics'] as $characterMetric) {
            $epoch->metrics()->firstOrCreate($characterMetric);
        }

        // Remove any metrics that are no longer provided by the game server (could happen on game updates)
        // TODO: How do we handle historical data? Do we keep it? Do we remove it?
        Metric::whereNotIn('id', array_column($data['metrics'], 'id'))->delete();

        $currentTimestamp = now();
        $characterMetrics = $data['character_metrics'];

        $alliances = Alliance::pluck('id');

        function metricValueOrNull($characterMetric, $key)
        {
            return isset($characterMetric[$key]) ? $characterMetric[$key] : null;
        }

        foreach ($characterMetrics as &$characterMetric) {
            // Make sure every metric has the same columns
            $characterMetric['character_id'] = metricValueOrNull($characterMetric, 'character_id');

            // A character may not have an alliance, in which case this wont be set
            $characterMetric['alliance_id'] = metricValueOrNull($characterMetric, 'alliance_id');

            // The alliance may not exist anymore if it was removed
            // TODO: Leave the alliance? Remove the foreign keys on client? I dunno yet.
            if ($characterMetric['alliance_id'] !== null) {
                $characterMetric['alliance_id'] = $alliances->contains($characterMetric['alliance_id']) ? $characterMetric['alliance_id'] : null;
            }

            $characterMetric['metric_id'] = metricValueOrNull($characterMetric, 'metric_id');
            $characterMetric['value'] = metricValueOrNull($characterMetric, 'value');

            $characterMetric['created_at'] = $currentTimestamp;
            $characterMetric['updated_at'] = $currentTimestamp;
        }

        CharacterMetric::upsert(
            $characterMetrics,
            uniqueBy: ['id', 'character_id', 'metric_id'],
            update: ['value']
        );

        return [
            'message' => 'Metrics submitted successfully',
        ];
    }
}
