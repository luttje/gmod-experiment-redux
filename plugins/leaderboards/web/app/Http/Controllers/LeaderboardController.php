<?php

namespace App\Http\Controllers;

use App\Models\Metric;
use Illuminate\Http\Request;

class LeaderboardController extends Controller
{
    public function index()
    {
        $metrics = Metric::getLatest();

        // TODO: How many queries are being run here? Do we need to run all of them to get just the overall leader?
        $overallLeader = Metric::getOverallScores($metrics)->first();

        return view('leaderboards.index', compact('metrics', 'overallLeader'));
    }

    public function overall()
    {
        $metrics = Metric::getLatest();

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
            return $characters->sortByDesc('pivot.created_at')->first();
        })->sortByDesc('pivot.value')->values()->map(function ($leader) {
            return [
                'character' => $leader,
                'value' => $leader->pivot->value,
            ];
        });

        return view('leaderboards.show', compact('metric', 'characterScores'));
    }
}
