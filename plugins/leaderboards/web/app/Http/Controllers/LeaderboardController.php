<?php

namespace App\Http\Controllers;

use App\Models\Metric;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\View;

class LeaderboardController extends Controller
{
    public function index()
    {
        $metrics = cache('metricScores');

        if (empty($metrics)) {
            return view('leaderboards.no-data');
        }

        $overallLeader = cache('overallLeader');

        View::share('lastUpdatedAt', $metrics['updatedAt']);
        unset($metrics['updatedAt']);

        return view('leaderboards.index', compact('metrics', 'overallLeader'));
    }

    public function overall()
    {
        $characterScores = cache('overallScores');

        View::share('lastUpdatedAt', $characterScores['updatedAt']);
        unset($characterScores['updatedAt']);

        return view('leaderboards.overall', compact('characterScores'));
    }

    public function show(Metric $metric)
    {
        $metrics = cache('metricScores');
        $characterScores = $metrics[$metric->id];

        if (empty($characterScores)) {
            return view('leaderboards.no-data');
        }

        $characterScores = $characterScores['scores'];
        View::share('lastUpdatedAt', $metrics['updatedAt']);

        return view('leaderboards.show', compact('metric', 'characterScores'));
    }
}
