<?php

namespace App;

use App\Models\Epoch;
use App\Rewards;

/**
 * This is where we setup what rewards are available for each epoch.
 */
const EPOCH_REWARDS = [
    'Beta Test Epoch' => [
        Rewards\ParticipationReward::class,
        Rewards\OverallLeaderReward::class,
    ],
    'Epoch 1' => [
        Rewards\ParticipationReward::class,
        Rewards\OverallLeaderReward::class,
    ],
];
