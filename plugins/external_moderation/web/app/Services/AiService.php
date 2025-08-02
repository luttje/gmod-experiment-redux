<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class AiService
{
    public static function chatCompletion(string $systemPrompt, array $schema, string|array $userMessage): array
    {
        $apiKey = config('app.openai.key');

        if (is_array($userMessage)) {
            $userMessage = json_encode($userMessage);
        }

        $data = [
            'model' => 'gpt-4.1',
            'response_format' => 'json',
            'temperature' => 0,
            'messages' => [
                [
                    'role' => 'system',
                    'content' => $systemPrompt,
                ],
                [
                    'role' => 'user',
                    'content' => $userMessage,
                ],
            ],
            'response_format' => [
                'type' => 'json_schema',
                'json_schema' => $schema,
            ],
        ];

        $response = Http::withToken($apiKey)
            ->withHeaders([
                'Content-Type' => 'application/json',
            ])
            ->post('https://api.openai.com/v1/chat/completions', $data);

        $responseData = $response->json();

        if (! isset($responseData['choices'][0]['message']['content'])) {
            throw new \Exception('Invalid response from OpenAI API');
        }

        $content = $responseData['choices'][0]['message']['content'];

        return json_decode($content, true);
    }
}
