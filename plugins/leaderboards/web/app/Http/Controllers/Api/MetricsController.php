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
        // If the request is x-www-form-urlencoded, then expand the 'json' value from the request into the request data.
        if ($request->header('Content-Type') === 'application/x-www-form-urlencoded') {
            $json = json_decode($request->input('json'), true);

            foreach ($json as $key => $value) {
                $request->request->set($key, $value);
            }

            $request->request->remove('json');
        } else {
            $headers = collect($request->header())->transform(function ($item) {
                return $item[0];
            });
            die(json_encode($headers, JSON_PRETTY_PRINT) . '    /    ' . json_encode($request->all(), JSON_PRETTY_PRINT));
        }

        $data = $request->validate([
            'epoch' => 'required|array:name,ends_at,started_at',
            'players' => 'required|array',
            'characters' => 'required|array',
            'alliances' => 'required|array',
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

        foreach ($metrics as $metric) {
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
