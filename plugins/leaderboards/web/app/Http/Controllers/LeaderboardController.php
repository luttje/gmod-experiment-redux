<?php

namespace App\Http\Controllers;

use App\Models\Epoch;
use App\Models\Metric;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\View;

class LeaderboardController extends Controller
{
    private static function shareCommonViewData(Epoch $selectedEpoch, array &$metrics)
    {
        $epochs = cache('epochs');
        $latestEpoch = Epoch::latest()->first();

        View::share('epochs', $epochs);
        View::share('latestEpoch', $latestEpoch);
        View::share('selectedEpoch', $selectedEpoch);

        if (empty($metrics)) {
            return;
        }

        View::share('lastUpdatedAt', $metrics['updatedAt']);
        unset($metrics['updatedAt']);
    }

    public function index(?Epoch $epoch = null)
    {
        $latestEpoch = Epoch::latest()->first();
        $epoch = $epoch ?? $latestEpoch;
        $leaderboardScores = Metric::leaderboardsFromCache($epoch);
        $metrics = $leaderboardScores['metricScores'];

        self::shareCommonViewData($epoch, $metrics);

        if (empty($metrics)) {
            return view('leaderboards.no-data');
        }

        $overallLeader = $leaderboardScores['overallLeader'];

        return view('leaderboards.index', compact('metrics', 'overallLeader'));
    }

    public function overall(?Epoch $epoch = null)
    {
        $epoch = $epoch ?? Epoch::latest()->first();
        $leaderboardScores = Metric::leaderboardsFromCache($epoch);
        $characterScores = isset($leaderboardScores['overallScores']) ? $leaderboardScores['overallScores'] : [];

        self::shareCommonViewData($epoch, $characterScores);

        return view('leaderboards.overall', compact('characterScores'));
    }

    public function show(Metric $metric, ?Epoch $epoch = null)
    {
        $epoch = $epoch ?? Epoch::latest()->first();
        $leaderboardScores = Metric::leaderboardsFromCache($epoch);
        $metrics = $leaderboardScores['metricScores'];
        $characterScores = isset($metrics[$metric->id]) ? $metrics[$metric->id] : [];

        self::shareCommonViewData($epoch, $metrics);

        $characterScores = isset($characterScores['scores']) ? $characterScores['scores'] : [];

        return view('leaderboards.show', compact('metric', 'characterScores'));
    }
}
