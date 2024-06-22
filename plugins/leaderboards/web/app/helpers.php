<?php

use App\Models\Character;
use App\Models\Epoch;
use App\Rewards\BaseReward;

use const App\EPOCH_REWARDS;

if (!function_exists('user')) {
    /**
     * Get the current user.
     *
     * @return \App\Models\User
     */
    function user()
    {
        return auth()->user();
    }
}

if (!function_exists('setupRewardForCharacter')) {
    /**
     * Setup the reward for the given character.
     */
    function setupRewardForCharacter(Character $character, string $rewardClass): BaseReward
    {
        assert(is_subclass_of($rewardClass, BaseReward::class));
        assert($rewardClass::canClaim($character));

        $data = [];
        $rewardClass::setup($character, $data);
        $reward = new $rewardClass($character, $data);

        return $reward;
    }
}


if (!function_exists('getRewardsForCharacter')) {
    /**
     * Returns reward instances for the given character's epoch.
     */
    function getRewardsForCharacter(Character $character): array
    {
        $epoch = $character->epoch->name;

        $availableRewards = array_filter(EPOCH_REWARDS[$epoch], function($rewardClass) use ($character) {
            assert(is_subclass_of($rewardClass, BaseReward::class));

            return $rewardClass::canClaim($character);
        });

        return array_map(function($rewardClass) use ($character) {
            return setupRewardForCharacter($character, $rewardClass)
                ->getName();
        }, $availableRewards);
    }
}


if (!function_exists('claimRewardsForCharacter')) {
    /**
     * Claims rewards for the given character.
     */
    function claimRewardsForCharacter(Character $character): void
    {
        $epoch = $character->epoch->name;

        $availableRewards = array_filter(EPOCH_REWARDS[$epoch], function($rewardClass) use ($character) {
            assert(is_subclass_of($rewardClass, BaseReward::class));

            return $rewardClass::canClaim($character);
        });

        foreach ($availableRewards as $rewardClass) {
            $reward = setupRewardForCharacter($character, $rewardClass);
            $reward->claim();
        }
    }
}
