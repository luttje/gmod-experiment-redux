<?php

namespace App\Rewards;

use App\Models\Character;
use App\Models\Metric;

class OverallLeaderReward extends BaseReward
{
    protected static string $name = 'Overall Leader';

    /**
     * @inheritDoc
     */
    public static function getDiscordRole(): ?string
    {
        return 'Hero of an Epoch';
    }

    /**
     * @inheritDoc
     */
    public static function getMedalImageStack(): array
    {
        return [
            'design001_blank2.png',
            'symbol_overall_leader.png' => 'shine',
        ];
    }

    /**
     * @inheritDoc
     */
    public static function canClaim(Character $character): bool
    {
        $cachedScores = Metric::leaderboardsFromCache($character->epoch);
        $overallLeader = $cachedScores['overallLeader']['character']['id'] ?? null;

        return $overallLeader === $character->id;
    }
}
