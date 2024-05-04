<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PlayerInfo;
use Illuminate\Http\Request;

class PlayerInfoController extends Controller
{
    public function submitPlayerInfo(Request $request)
    {
        $this->fixRequest($request);

        $data = $request->validate([
            'steam_id' => 'required|string',
            'steam_name' => 'required|string',
            'character_name' => 'nullable|string',
            'character_id' => 'nullable|integer',
            'ip_address' => 'required|string',
        ]);

        $playerInfo = PlayerInfo::updateOrCreate(
            [
                'steam_id' => $data['steam_id']
            ],
            $data
        );

        return response()->json($playerInfo);
    }
}
