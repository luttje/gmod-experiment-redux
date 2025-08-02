<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Sanction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SanctionController extends Controller
{
    /**
     * Get all currently active sanctions
     */
    public function index(Request $request): JsonResponse
    {
        // Get all sanctions and filter to active ones
        $sanctions = Sanction::query()
            ->with(['issuer:id,name']) // Load issuer info but only id and name
            ->orderBy('created_at', 'desc')
            ->get()
            ->filter(function (Sanction $sanction) {
                return $sanction->isActive();
            });

        // Transform the data for API consumption
        $activeSanctions = $sanctions->map(function (Sanction $sanction) {
            return [
                'id' => $sanction->id,
                'steam_id' => $sanction->steam_id,
                'steam_name' => $sanction->steam_name,
                'character_name' => $sanction->character_name,
                'character_id' => $sanction->character_id,
                'ip_address' => $sanction->ip_address,
                'type' => $sanction->type,
                'reason' => $sanction->reason,
                'expires_in' => $sanction->expires_at?->diffForHumans(),
                'issued_at' => $sanction->created_at->toISOString(),
                'issued_by' => $sanction->issuer?->name,
                'rule_id' => $sanction->rule_id,
                'escalation_level' => $sanction->escalation_level,
                'is_permanent' => is_null($sanction->expires_at),
            ];
        })->values(); // Reset array keys

        return response()->json([
            'success' => true,
            'data' => $activeSanctions,
            'count' => $activeSanctions->count(),
            'timestamp' => now()->toISOString(),
        ]);
    }

    /**
     * Get active sanctions for a specific player by Steam ID
     */
    public function player(Request $request, string $steamId): JsonResponse
    {
        $sanctions = Sanction::getPlayerSanctions($steamId)
            ->filter(function (Sanction $sanction) {
                return $sanction->isActive();
            });

        $activeSanctions = $sanctions->map(function (Sanction $sanction) {
            return [
                'id' => $sanction->id,
                'type' => $sanction->type,
                'reason' => $sanction->reason,
                'expires_at' => $sanction->expires_at?->toISOString(),
                'issued_at' => $sanction->created_at->toISOString(),
                'rule_id' => $sanction->rule_id,
                'escalation_level' => $sanction->escalation_level,
                'is_permanent' => is_null($sanction->expires_at),
            ];
        })->values();

        return response()->json([
            'success' => true,
            'steam_id' => $steamId,
            'data' => $activeSanctions,
            'count' => $activeSanctions->count(),
            'timestamp' => now()->toISOString(),
        ]);
    }

    /**
     * Get active sanctions by type (mute, ban, etc.)
     */
    public function byType(Request $request, string $type): JsonResponse
    {
        // Validate the type
        if (! in_array($type, ['mute', /*'kick',*/ 'ban'])) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid sanction type. Must be one of: mute or ban', // 'kick' is not used anymore
            ], 400);
        }

        $sanctions = Sanction::where('type', $type)
            ->with(['issuer:id,name'])
            ->orderBy('created_at', 'desc')
            ->get()
            ->filter(function (Sanction $sanction) {
                return $sanction->isActive();
            });

        $activeSanctions = $sanctions->map(function (Sanction $sanction) {
            return [
                'id' => $sanction->id,
                'steam_id' => $sanction->steam_id,
                'steam_name' => $sanction->steam_name,
                'character_name' => $sanction->character_name,
                'character_id' => $sanction->character_id,
                'ip_address' => $sanction->ip_address,
                'reason' => $sanction->reason,
                'expires_at' => $sanction->expires_at?->toISOString(),
                'issued_at' => $sanction->created_at->toISOString(),
                'issued_by' => $sanction->issuer?->name,
                'rule_id' => $sanction->rule_id,
                'escalation_level' => $sanction->escalation_level,
                'is_permanent' => is_null($sanction->expires_at),
            ];
        })->values();

        return response()->json([
            'success' => true,
            'type' => $type,
            'data' => $activeSanctions,
            'count' => $activeSanctions->count(),
            'timestamp' => now()->toISOString(),
        ]);
    }

    /**
     * Check if a specific player has any active sanctions
     */
    public function check(Request $request, string $steamId): JsonResponse
    {
        $activeSanctions = Sanction::getPlayerSanctions($steamId)
            ->filter(function (Sanction $sanction) {
                return $sanction->isActive();
            });

        $hasBan = $activeSanctions->where('type', 'ban')->isNotEmpty();
        $hasMute = $activeSanctions->where('type', 'mute')->isNotEmpty();

        return response()->json([
            'success' => true,
            'steam_id' => $steamId,
            'has_active_sanctions' => $activeSanctions->isNotEmpty(),
            'has_ban' => $hasBan,
            'has_mute' => $hasMute,
            'active_sanctions_count' => $activeSanctions->count(),
            'sanctions' => $activeSanctions->map(function (Sanction $sanction) {
                return [
                    'type' => $sanction->type,
                    'expires_at' => $sanction->expires_at?->toISOString(),
                    'is_permanent' => is_null($sanction->expires_at),
                ];
            })->values(),
            'timestamp' => now()->toISOString(),
        ]);
    }
}
