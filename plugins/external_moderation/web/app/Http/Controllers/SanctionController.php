<?php

namespace App\Http\Controllers;

use App\Models\ChatLog;
use App\Models\Sanction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SanctionController extends Controller
{
    /**
     * Show the sanction form for a specific chat log
     */
    public function create(ChatLog $chatLog)
    {
        // Get previous sanctions for this player
        $previousSanctions = Sanction::getPlayerSanctions($chatLog->steam_id);

        // Get rules and calculate next escalation levels
        $rules = require app_path('Data/Rules.php');
        $rulesWithEscalations = [];

        foreach ($rules as $ruleId => $rule) {
            $offenseCount = Sanction::getOffenseCount($chatLog->steam_id, $ruleId);
            $nextEscalationLevel = Sanction::getNextEscalationLevel($chatLog->steam_id, $ruleId);

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

        return view('sanctions.create', compact('chatLog', 'previousSanctions', 'rulesWithEscalations'));
    }

    /**
     * Store a new sanction
     */
    public function store(Request $request, ChatLog $chatLog)
    {
        $request->validate([
            'type' => 'required|in:mute,kick,ban',
            'reason' => 'required|string',
            'expires_at' => 'nullable|date',
            'rule_id' => 'nullable|string',
            'escalation_level' => 'nullable|integer|min:0',
        ]);

        return DB::transaction(function () use ($request, $chatLog) {
            // Mark chat log as moderated
            $chatLog->update([
                'moderated_at' => now(),
                'moderated_by' => auth()->id(),
            ]);

            // Create the sanction
            Sanction::create([
                'steam_name' => $chatLog->steam_name,
                'steam_id' => $chatLog->steam_id,
                'character_name' => $chatLog->character_name,
                'character_id' => $chatLog->character_id,
                'ip_address' => $chatLog->ip_address,
                'type' => $request->type,
                'reason' => $request->reason,
                'expires_at' => $request->expires_at,
                'issued_by' => auth()->id(),
                'rule_id' => $request->rule_id,
                'escalation_level' => $request->escalation_level,
                'chat_log_id' => $chatLog->id,
            ]);

            return redirect()
                ->route('chat-logs.moderation')
                ->with('success', 'Sanction has been applied successfully.');
        });
    }
}
