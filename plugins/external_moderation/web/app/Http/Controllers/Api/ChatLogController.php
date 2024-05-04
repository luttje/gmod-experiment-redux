<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChatLog;
use App\Models\PlayerInfo;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ChatLogController extends Controller
{
    public function submitChatLog(Request $request)
    {
        $this->fixRequest($request);

        $data = $request->validate([
            'chat_type' => 'required|string',

            'steam_id' => 'required|string',
            'steam_name' => 'required|string',
            'character_id' => 'nullable|integer',
            'character_name' => 'nullable|string',
            'ip_address' => 'required|string',
            'message' => 'nullable|string',
        ]);

        $chatLog = ChatLog::create($data);

        return response()->json($chatLog);
    }

    public function submitVoiceChatLog(Request $request)
    {
        $this->fixRequest($request);

        $data = $request->validate([
            'steam_id' => 'required|string',
            'message' => 'required|string',
            'voice_chat_path' => 'required|string',
        ]);

        // Fetch the player's info from the database
        $playerInfo = PlayerInfo::where('steam_id', $data['steam_id'])->first();

        if (! $playerInfo) {
            // This really shouldn't happen, so let's extra log it
            Log::error('Player info not found on voice chat', $data);
            return response()->json(['error' => 'Player info not found'], 404);
        }

        $data['steam_name'] = $playerInfo->steam_name;
        $data['character_id'] = $playerInfo->character_id;
        $data['character_name'] = $playerInfo->character_name;
        $data['ip_address'] = $playerInfo->ip_address;

        $data['chat_type'] = 'voice';

        $chatLog = ChatLog::create($data);

        return response()->json($chatLog);
    }
}
