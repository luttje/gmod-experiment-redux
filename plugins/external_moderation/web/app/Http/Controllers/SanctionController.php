<?php

namespace App\Http\Controllers;

use App\Models\ChatLog;
use App\Models\Sanction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SanctionController extends Controller
{
    private function baseCreate(string $steamId, ?ChatLog $chatLog = null)
    {
        $player = PlayerController::getPlayerInfo($steamId);

        // Get previous sanctions for this player
        $previousSanctions = Sanction::getPlayerSanctions($steamId);

        // Get rules and calculate next escalation levels
        $rules = require app_path('Data/Rules.php');
        $rulesWithEscalations = [];

        foreach ($rules as $ruleId => $rule) {
            $offenseCount = Sanction::getOffenseCount($steamId, $ruleId);
            $nextEscalationLevel = Sanction::getNextEscalationLevel($steamId, $ruleId);

            $rulesWithEscalations[$ruleId] = [
                'rule' => $rule,
                'offense_count' => $offenseCount,
                'next_escalation_level' => $nextEscalationLevel,
                'escalations' => array_map(function ($escalation, $index) use ($offenseCount) {
                    return [
                        ...$escalation,
                        'is_used' => $index < $offenseCount,
                    ];
                }, $rule['escalations'], array_keys($rule['escalations'])),
            ];
        }

        return view('sanctions.create', compact('chatLog', 'player', 'previousSanctions', 'rulesWithEscalations'));
    }

    /**
     * Show the sanction form for a specific chat log
     */
    public function create(ChatLog $chatLog)
    {
        return $this->baseCreate($chatLog->steam_id, $chatLog);
    }

    /**
     * Show the sanction form for a specific player
     */
    public function createForPlayer(string $playerSteamID)
    {
        return $this->baseCreate($playerSteamID);
    }

    /**
     * Store a new sanction
     */
    public function store(Request $request, ?ChatLog $chatLog = null)
    {
        $request->validate([
            'type' => 'required|in:mute,ban', // no kicking, since its hard to implement with our polling API, just ban 5 mins or fewer
            'reason' => 'required|string',
            'expires_at' => 'nullable|date',
            'rule_id' => 'nullable|string',
            'escalation_level' => 'nullable|integer|min:0',

            'steam_name' => 'required|string|max:255',
            'steam_id' => 'required|string|max:255',
            'character_name' => 'nullable|string|max:255',
            'character_id' => 'nullable|integer',
            'ip_address' => 'required|string|max:255',
        ]);

        return DB::transaction(function () use ($request, $chatLog) {
            if ($chatLog) {
                // Mark chat log as moderated
                $chatLog->update([
                    'moderated_at' => now(),
                    'moderated_by' => auth()->id(),
                ]);
            }

            // Create the sanction
            Sanction::create([
                'steam_name' => $request->steam_name,
                'steam_id' => $request->steam_id,
                'character_name' => $request->character_name,
                'character_id' => $request->character_id,
                'ip_address' => $request->ip_address,
                'type' => $request->type,
                'reason' => $request->reason,
                'expires_at' => $request->expires_at,
                'issued_by' => auth()->id(),
                'rule_id' => $request->rule_id,
                'escalation_level' => $request->escalation_level,
                'chat_log_id' => $chatLog?->id ?? null,
            ]);

            return redirect()
                ->route('chat-logs.moderation')
                ->with('success', 'Sanction has been applied successfully.');
        });
    }

    /**
     * Show the details of a specific sanction
     */
    public function show(Sanction $sanction)
    {
        $relatedSanctions = Sanction::where('steam_id', $sanction->steam_id)
            ->where('id', '!=', $sanction->id)
            ->get();

        return view('sanctions.show', compact('sanction', 'relatedSanctions'));
    }

    /**
     * Revoke a sanction (delete it)
     */
    public function revoke(Sanction $sanction)
    {
        $sanction->delete();

        return redirect()
            ->route('sanctions.index')
            ->with('success', 'Sanction has been revoked successfully.');
    }
}
