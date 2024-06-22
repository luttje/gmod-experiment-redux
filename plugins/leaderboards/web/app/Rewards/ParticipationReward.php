<?php

namespace App\Rewards;

use App\Models\Character;

class ParticipationReward extends BaseReward
{
    protected static string $name = 'Participated in {epoch_name}';

    /**
     * @inheritDoc
     */
    public static function getMedalImageStack(): array
    {
        return [
            'ribbon001.png',
            'design003_blank.png' => 'shine',
            // TODO: Participation symbols for other epochs
            'symbol_epoch_1.png' => 'shine',
        ];
    }

    /**
     * @inheritDoc
     */
    public static function setup(Character $character, array &$data): void
    {
        // Set the epoch name so it will be included in the reward name
        $data['epoch_name'] = $character->epoch->name;
    }
}
