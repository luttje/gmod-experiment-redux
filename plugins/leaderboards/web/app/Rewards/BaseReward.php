<?php

namespace App\Rewards;

use App\Models\Character;

abstract class BaseReward
{
    protected static string $name = 'A reward';

    public function __construct(
        protected Character $character,
        protected array $data = []
    ) {}

    /**
     * Formats the reward name using all parameters in the data array
     */
    public function getName(): string
    {
        $name = static::$name;

        foreach ($this->data as $key => $value) {
            $name = str_replace('{' . $key . '}', $value, $name);
        }

        return $name;
    }

    /**
     * Returns the data array for the reward.
     */
    public function getData(): array
    {
        return $this->data;
    }

    /**
     * Saves the claimed reward to the database.
     */
    public function claim(): void
    {
        $this->character->characterRewards()->create([
            'reward_class' => static::class,
            'data' => $this->getData(),
        ]);
    }

    /**
     * Called when a reward needs to be setup for a character.
     *
     * This should only set data and not save anything to the database as
     * the reward may not be claimed yet.
     */
    public static function setup(Character $character, array &$data): void
    {

    }

    /**
     * Called to check if the reward can be claimed.
     */
    public static function canClaim(Character $character): bool
    {
        return true;
    }
}
