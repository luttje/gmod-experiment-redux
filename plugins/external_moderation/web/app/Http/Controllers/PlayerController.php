<?php

namespace App\Http\Controllers;

use App\Models\ChatLog;
use App\Models\PlayerInfo;
use App\Models\Sanction;
use Illuminate\Http\Request;

class PlayerController extends Controller
{
    /**
     * Get player information by Steam ID
     */
    public static function getPlayerInfo(string $steamId)
    {
        // Find the player info
        $player = PlayerInfo::where('steam_id', $steamId)->first();

        if (! $player) {
            // If no PlayerInfo exists, try to find from sanctions or chat logs
            // This is a fallback for during development, since in production a PlayerInfo should always exist
            $sanction = Sanction::where('steam_id', $steamId)->first();
            $chatLog = ChatLog::where('steam_id', $steamId)->first();

            if (! $sanction && ! $chatLog) {
                abort(404, 'Player not found');
            }

            // Create a temporary player object for display
            $player = (object) [
                'steam_id' => $steamId,
                'steam_name' => $sanction->steam_name ?? $chatLog->steam_name ?? 'Unknown',
                'character_name' => $sanction->character_name ?? $chatLog->character_name ?? null,
                'character_id' => $sanction->character_id ?? $chatLog->character_id ?? null,
                'ip_address' => $sanction->ip_address ?? $chatLog->ip_address ?? null,
                'rank' => 'player',
                'created_at' => $sanction->created_at ?? $chatLog->created_at ?? now(),
                'anonymized_at' => null,
            ];
        }

        return $player;
    }

    /**
     * Display the specified player's profile and history
     */
    public function show(Request $request, string $steamId)
    {
        $player = PlayerController::getPlayerInfo($steamId);

        // Get all sanctions for this player
        $sanctions = Sanction::where('steam_id', $steamId)
            ->orderBy('created_at', 'desc')
            ->get();

        // Get chat logs for this player (limit to recent ones for performance)
        $chatLogs = ChatLog::where('steam_id', $steamId)
            ->orderBy('created_at', 'desc')
            ->limit(100)
            ->get();

        // Get flagged chat logs
        $flaggedChatLogs = ChatLog::where('steam_id', $steamId)
            ->whereNotNull('flagged_reason')
            ->orderBy('created_at', 'desc')
            ->get();

        // Calculate statistics
        $stats = $this->calculatePlayerStats($steamId, $sanctions, $chatLogs);

        // Get rule violation breakdown
        $ruleViolations = $this->getRuleViolationBreakdown($sanctions);

        return view('players.show', compact(
            'player',
            'sanctions',
            'chatLogs',
            'flaggedChatLogs',
            'stats',
            'ruleViolations'
        ));
    }

    /**
     * Display index of all player info's we have received from the server
     */
    public function index()
    {
        $players = PlayerInfo::all();

        return view('players.index', compact('players'));
    }

    /**
     * Calculate various statistics for the player
     */
    private function calculatePlayerStats(string $steamId, $sanctions, $chatLogs): array
    {
        $activeSanctions = $sanctions->filter(fn ($s) => $s->isActive());
        $expiredSanctions = $sanctions->filter(fn ($s) => ! $s->isActive());

        // Sanction type breakdown
        $sanctionTypes = $sanctions->groupBy('type')->map(fn ($group) => $group->count());

        // Recent activity (last 30 days)
        $recentSanctions = $sanctions->filter(fn ($s) => $s->created_at->isAfter(now()->subDays(30)));
        $recentChatLogs = $chatLogs->filter(fn ($c) => $c->created_at->isAfter(now()->subDays(30)));

        // First and last seen
        $firstSeen = $chatLogs->min('created_at') ?? $sanctions->min('created_at');
        $lastSeen = $chatLogs->max('created_at') ?? $sanctions->max('created_at');

        return [
            'total_sanctions' => $sanctions->count(),
            'active_sanctions' => $activeSanctions->count(),
            'expired_sanctions' => $expiredSanctions->count(),
            'total_chat_messages' => $chatLogs->count(),
            'flagged_messages' => $chatLogs->filter(fn ($c) => $c->flagged_reason)->count(),
            'recent_sanctions_30d' => $recentSanctions->count(),
            'recent_messages_30d' => $recentChatLogs->count(),
            'sanction_types' => $sanctionTypes,
            'first_seen' => $firstSeen,
            'last_seen' => $lastSeen,
            'time_since_last_sanction' => $sanctions->first()?->created_at?->diffForHumans(),
        ];
    }

    /**
     * Get rule violation breakdown with escalation information
     */
    private function getRuleViolationBreakdown($sanctions): array
    {
        $rules = require app_path('Data/Rules.php');
        $violations = [];

        foreach ($sanctions->whereNotNull('rule_id') as $sanction) {
            $ruleId = $sanction->rule_id;

            if (! isset($violations[$ruleId])) {
                $violations[$ruleId] = [
                    'rule' => $rules[$ruleId] ?? ['title' => 'Unknown Rule', 'description' => 'Rule not found'],
                    'total_violations' => 0,
                    'escalation_levels' => [],
                    'last_violation' => null,
                ];
            }

            $violations[$ruleId]['total_violations']++;
            $violations[$ruleId]['escalation_levels'][] = $sanction->escalation_level;

            if (! $violations[$ruleId]['last_violation'] ||
                $sanction->created_at->isAfter($violations[$ruleId]['last_violation'])) {
                $violations[$ruleId]['last_violation'] = $sanction->created_at;
            }
        }

        // Sort by total violations descending
        uasort($violations, fn ($a, $b) => $b['total_violations'] <=> $a['total_violations']);

        return $violations;
    }

    /**
     * Get recent activity for the player
     */
    public function recentActivity(Request $request, string $steamId)
    {
        $days = $request->get('days', 30);

        $sanctions = Sanction::where('steam_id', $steamId)
            ->where('created_at', '>=', now()->subDays($days))
            ->orderBy('created_at', 'desc')
            ->get();

        $chatLogs = ChatLog::where('steam_id', $steamId)
            ->where('created_at', '>=', now()->subDays($days))
            ->orderBy('created_at', 'desc')
            ->limit(50)
            ->get();

        return response()->json([
            'sanctions' => $sanctions,
            'chat_logs' => $chatLogs,
        ]);
    }
}
