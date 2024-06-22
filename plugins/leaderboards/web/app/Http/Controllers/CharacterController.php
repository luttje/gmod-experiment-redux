<?php

namespace App\Http\Controllers;

use App\Models\Character;
use App\Models\Epoch;
use App\Models\Metric;
use Illuminate\Pagination\AbstractPaginator;
use RealRashid\SweetAlert\Facades\Alert;

class CharacterController extends Controller
{
    public function index()
    {
        /** @var AbstractPaginator $characters */
        $characters = Character::with(['player', 'epoch', 'characterRewards'])
            ->where('steam_id', user()->steam_id)
            ->orderBy('id', 'desc')
            ->paginate(25);

        // Retrieve all metrics with their associated epochs
        $metrics = Metric::with('epoch')->get()->keyBy('id');

        // Enhance each character with metric scores
        $characters->getCollection()->each(function ($character) use ($metrics) {
            // Retrieve cached scores for the character's epoch
            $cachedScores = Metric::leaderboardsFromCache($character->epoch);

            // Handle overall score
            $overallLeader = $cachedScores['overallLeader'] ?? null;
            $overallScore = $cachedScores['overallScores'][$character->id]['sum'] ?? 0;
            $characterScores = [
                -1 => [
                    'sum' => $overallScore,
                    'name' => 'Overall',
                    'isLeader' => $overallLeader && $overallLeader['character']['id'] === $character->id
                ]
            ];

            unset($cachedScores['metricScores']['updatedAt']);

            // Handle metric-specific scores
            foreach ($cachedScores['metricScores'] as $metricId => $metricData) {
                $isLeader = isset($metricData['leader'])
                    ? $metricData['leader']['character']['id'] === $character->id
                    : false;

                $characterScores[$metricId] = [
                    'sum' => $metricData['scores'][$character->id]['sum'] ?? 0,
                    'name' => $metrics[$metricId]->name ?? 'Unknown',
                    'isLeader' => $isLeader
                ];
            }

            $character->scores = $characterScores;
        });

        return view('characters.index', compact('characters'));
    }

    /**
     * Shows the available rewards for the character and allows the player to claim them.
     */
    public function claimRewards(Character $character)
    {
        if ($character->epoch->ends_at > now()) {
            alert()->error('You cannot claim rewards until the epoch has ended.');
            return redirect()
                ->route('characters.index');
        }

        $rewards = getRewardsForCharacter($character);

        return view('characters.claim-rewards', compact('character', 'rewards'));
    }

    /**
     * Confirms the rewards for the character and marks them as claimed.
     */
    public function confirmClaimRewards(Character $character)
    {
        if ($character->epoch->ends_at > now()) {
            alert()->error('You cannot claim rewards until the epoch has ended.');
            return redirect()
                ->route('characters.index');
        }

        claimRewardsForCharacter($character);

        return redirect()->route('characters.index');
    }
}
