<?php

namespace App\Rewards;

use App\Models\Character;
use App\Services\Discord;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Contracts\Support\Renderable;

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
     *
     * Override this to execute additional logic when claiming a reward.
     * Be sure to call parent::claim() if you override this method.
     */
    public function claim(): void
    {
        $discordRole = static::getDiscordRole();

        if ($discordRole) {
            Discord::setRoleForMember(user()->discord_id, $discordRole);
        }

        $this->character->characterRewards()->create([
            'reward_class' => static::class,
            'data' => $this->getData(),
        ]);
    }

    /**
     * Draws the images that represent the reward.
     */
    public function render(): string
    {
        return view('rewards.base', [
            'reward' => $this,
            'medalImageStack' => static::getMedalImageStack(),
        ])->render();
    }

    /**
     * Returns a discord role that should be assigned to the user
     * (and created if it doesn't exist).
     */
    public static function getDiscordRole(): ?string
    {
        return null;
    }

    /**
     * Returns the images that represent the reward.
     * The path of the images is relative to
     * public/images/medals/
     */
    public static function getMedalImageStack(): array
    {
        return [
            'design001_blank2.png',
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

    }

    /**
     * Called to check if the reward can be claimed.
     */
    public static function canClaim(Character $character): bool
    {
        return true;
    }
}
