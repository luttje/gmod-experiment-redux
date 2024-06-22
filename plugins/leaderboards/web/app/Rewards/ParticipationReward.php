<?php

namespace App\Rewards;

use App\Models\Character;

class ParticipationReward extends BaseReward
{
    protected static string $name = 'Participated in {epoch_name}';

    public function getMedalImageStack(): array
    {
        return [
            'design003_blank.png',
            'ribbon001.png',
            'symbol_epoch_1.png',
        ];
    }

    /**
     * Called when a reward needs to be setup for a character.
     *
     * This should only set data and not save anything to the database as
     * the reward may not be claimed yet.
     */
    public static function setup(Character $character, array &$data): void
    {
        // Set the epoch name so it will be included in the reward name
        $data['epoch_name'] = $character->epoch->name;
    }
}
