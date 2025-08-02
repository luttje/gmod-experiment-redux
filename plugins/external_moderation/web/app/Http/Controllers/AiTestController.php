<?php

namespace App\Http\Controllers;

use App\Services\AiService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AiTestController extends Controller
{
    /**
     * Show the AI test page
     */
    public function index()
    {
        return view('sanctions.ai-tester');
    }

    /**
     * Test character name and description moderation
     */
    public function testCharacterModeration(Request $request): JsonResponse
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
        ]);

        try {
            $response = AiService::doCharacterModeration(
                $request->input('name'),
                $request->input('description', ''),
            );

            return response()->json($response);

        } catch (\Exception $e) {
            return response()->json([
                'error' => true,
                'message' => 'AI service error: '.$e->getMessage(),
            ], 500);
        }
    }

    /**
     * Test chat content moderation
     */
    public function testChatModeration(Request $request): JsonResponse
    {
        $request->validate([
            'message' => 'required|string|max:1000',
            'chat_type' => 'required|string|in:ic,ooc,voice',
            'rank' => 'required|string|in:superadmin,admin,player',
        ]);

        try {
            $response = AiService::doChatModeration(
                $request->input('message'),
                $request->input('chat_type'),
                $request->input('rank'),
            );

            return response()->json($response);

        } catch (\Exception $e) {
            return response()->json([
                'error' => true,
                'message' => 'AI service error: '.$e->getMessage(),
            ], 500);
        }
    }
}
