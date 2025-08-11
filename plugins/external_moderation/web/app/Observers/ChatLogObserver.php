<?php

namespace App\Observers;

use App\Jobs\ProcessChatModerationJob;
use App\Models\ChatLog;

class ChatLogObserver
{
    /**
     * Handle the ChatLog "created" event.
     */
    public function created(ChatLog $chatLog): void
    {
        $apiKey = config('app.openai.key');

        if (empty($apiKey)) {
            return;
        }

        // Only queue AI moderation if there's a message to analyze
        if (! empty($chatLog->message)) {
            // Dispatch with a small delay to allow for any immediate processing
            ProcessChatModerationJob::dispatch($chatLog)->delay(now()->addSeconds(5));
        }
    }

    /**
     * Handle the ChatLog "updated" event.
     */
    public function updated(ChatLog $chatLog): void
    {
        $apiKey = config('app.openai.key');

        if (empty($apiKey)) {
            return;
        }

        // If message was added/updated and not yet processed, queue for moderation
        if ($chatLog->wasChanged('message') &&
            ! empty($chatLog->message) &&
            is_null($chatLog->flagged_at) &&
            is_null($chatLog->moderated_at)) {

            ProcessChatModerationJob::dispatch($chatLog)->delay(now()->addSeconds(5));
        }
    }
}
