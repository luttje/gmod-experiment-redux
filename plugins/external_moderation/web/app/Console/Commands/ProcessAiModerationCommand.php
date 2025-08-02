<?php

namespace App\Console\Commands;

use App\Jobs\ProcessChatModerationJob;
use App\Models\ChatLog;
use Illuminate\Console\Command;

class ProcessAiModerationCommand extends Command
{
    protected $signature = 'moderation:process-ai {--batch-size=50 : Number of chat logs to process per batch}';

    protected $description = 'Process unmoderated chat logs through AI moderation system';

    public function handle(): int
    {
        $batchSize = (int) $this->option('batch-size');

        $this->info('Starting AI moderation processing...');

        // Get unprocessed chat logs (not flagged, not moderated, and has message content)
        $chatLogs = ChatLog::whereNull('flagged_at')
            ->whereNull('moderated_at')
            ->whereNotNull('message')
            ->where('message', '!=', '')
            ->orderBy('created_at', 'asc')
            ->limit($batchSize)
            ->get();

        if ($chatLogs->isEmpty()) {
            $this->info('No chat logs to process.');

            return self::SUCCESS;
        }

        $this->info("Processing {$chatLogs->count()} chat logs...");

        $processed = 0;
        foreach ($chatLogs as $chatLog) {
            try {
                ProcessChatModerationJob::dispatch($chatLog);
                $processed++;

                if ($processed % 10 === 0) {
                    $this->info("Queued {$processed} jobs...");
                }
            } catch (\Exception $e) {
                $this->error("Failed to queue job for chat log {$chatLog->id}: {$e->getMessage()}");
            }
        }

        $this->info("Successfully queued {$processed} moderation jobs.");

        return self::SUCCESS;
    }
}
