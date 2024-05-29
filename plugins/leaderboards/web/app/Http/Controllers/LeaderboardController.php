<?php

namespace App\Http\Controllers;

use App\Models\Metric;
use Illuminate\Http\Request;

class LeaderboardController extends Controller
{
    public function index()
    {
        $metrics = Metric::withEagerRelations();

        if ($metrics->isEmpty()) {
            return view('leaderboards.no-data');
        }

        // TODO: How many queries are being run here? Do we need to run all of them to get just the overall leader?
        $overallLeader = Metric::getOverallScores($metrics)->first();

        $metrics = $metrics->each(function ($metric) {
            $metric->leader = (object)$metric->characters->groupBy('id')->map(function ($characters) {
                // Because we're grouped by character ID, we can just grab the first character to get the character name.
                $character = $characters->first();
                return [
                    'name' => $character->name,
                    'player' => $character->player,
                    'sum' => $characters->sum('pivot.value'),
                ];
            })->sortByDesc('value')->first();
        });

        return view('leaderboards.index', compact('metrics', 'overallLeader'));
    }

    public function overall()
    {
        $metrics = Metric::withEagerRelations();

        $overallLeaders = Metric::getOverallScores($metrics);
        $characterScores = $overallLeaders->map(function ($leader) {
            return [
                'character' => $leader['character'],
                'value' => $leader['value'],
            ];
        });

        return view('leaderboards.overall', compact('characterScores'));
    }

    public function show(Metric $metric)
    {
        $metric->load([
            'characters.player',
        ]);

        $characterScores = $metric->characters->groupBy('id')->map(function ($characters) {
            return [
                'character' => $characters->first(),
                'value' => $characters->sum('pivot.value'),
            ];
        })->sortByDesc('value')->values();

        return view('leaderboards.show', compact('metric', 'characterScores'));
    }
}
