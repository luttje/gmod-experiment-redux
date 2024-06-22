<?php

namespace App\Rewards;

use App\Models\Character;
use App\Models\Metric;

class OverallLeaderReward extends BaseReward
{
    protected static string $name = 'Overall Leader';

    /**
     * Called to check if the reward can be claimed.
     */
    public static function canClaim(Character $character): bool
    {
        $cachedScores = Metric::leaderboardsFromCache($character->epoch);
        $overallLeader = $cachedScores['overallLeader']['character']['id'] ?? null;

        return $overallLeader === $character->id;
    }
}
