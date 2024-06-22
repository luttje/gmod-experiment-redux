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
use Illuminate\Support\Facades\Log;

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

        $epoch = Epoch::updateOrCreate([
            'name' => $data['epoch']['name'],
        ], $data['epoch']);

        // If the epoch ended more than 1 hour ago (buffer for slow final submission) we reject the submission
        if ($epoch->ends_at->addHour()->isPast()) {
            return response()->json([
                'message' => 'Epoch has ended, no more metrics can be submitted',
            ], 400);
        }

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

        foreach ($characterMetrics as $key => &$characterMetric) {
            // Make sure every metric has the same columns
            $characterMetric['character_id'] = metricValueOrNull($characterMetric, 'character_id');

            // If the character was removed by the player, we should not store the metric
            if ($characterMetric['character_id'] === null || !$epoch->characters->contains($characterMetric['character_id'])) {
                Log::error('Character metric without character_id', [
                    'character_metric' => $characterMetric,
                ]);
                unset($characterMetrics[$key]);
                continue;
            }

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

        // Chunk upserting to avoid getting "Prepared statement contains too many placeholders" error
        // TODO: Stop sending everything to fix this correctly, instead only send new metrics
        $characterMetricChunks = array_chunk($characterMetrics, 5000);

        foreach ($characterMetricChunks as $chunk) {
            try {
                CharacterMetric::upsert(
                    $chunk,
                    uniqueBy: ['id', 'character_id', 'metric_id'],
                    update: ['value']
                );
            } catch (\Exception $e) {
                // Fail by ignoring and just error logging
                Log::error('Failed to upsert character metrics', [
                    'error' => $e->getMessage(),
                    'chunk' => $chunk,
                ]);
            }
        }

        Metric::precacheLeaderboards();
        Epoch::precacheEpochs();

        return [
            'message' => 'Metrics submitted successfully',
        ];
    }
}
