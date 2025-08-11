<?php

namespace App\Jobs;

use App\Models\ChatLog;
use App\Models\Sanction;
use App\Services\AiService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class ProcessChatModerationJob implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    protected ChatLog $chatLog;

    public function __construct(ChatLog $chatLog)
    {
        $this->chatLog = $chatLog;
    }

    public function handle(): void
    {
        $apiKey = config('app.openai.key');

        if (empty($apiKey)) {
            // If no key is setup, we don't do any automated moderation/flagging.
            return;
        }

        try {
            // Skip if already processed
            if ($this->chatLog->flagged_at !== null || $this->chatLog->moderated_at !== null) {
                return;
            }

            // Skip if no message to analyze (e.g., voice chat not yet transcribed)
            if (empty($this->chatLog->message)) {
                return;
            }

            // Get AI moderation result
            $result = AiService::doChatModeration(
                $this->chatLog->message,
                $this->chatLog->chat_type,
                $this->chatLog->rank
            );

            $this->processAiResult($result);
        } catch (\Exception $e) {
            Log::error('AI moderation failed', [
                'chat_log_id' => $this->chatLog->id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            // Flag for human review on AI failure
            $this->chatLog->update([
                'flagged_at' => now(),
                'flagged_reason' => 'AI moderation failed: '.$e->getMessage(),
            ]);
        }
    }

    protected function processAiResult(array $result): void
    {
        $classification = $result['classification'];
        $ruleId = $result['rule_id'];
        $reasoning = $result['reasoning'];

        switch ($classification) {
            case 'SAFE':
                // Mark as automatically moderated (safe)
                $this->chatLog->update([
                    'moderated_at' => now(),
                    'moderated_by' => null, // null indicates AI moderation
                ]);
                break;

            case 'VIOLATION':
                Log::info('Processing violation', [
                    'chat_log_id' => $this->chatLog->id,
                    'rule_id' => $ruleId,
                    'can_ai_enforce' => $ruleId ? $this->canAiEnforce($ruleId) : false,
                ]);

                if ($ruleId && $this->canAiEnforce($ruleId)) {
                    $this->applyAutoSanction($ruleId, $reasoning);
                } else {
                    $this->flagForHumanReview($ruleId, $reasoning);
                }
                break;

            case 'FLAG':
                Log::info('Flagging for human review', [
                    'chat_log_id' => $this->chatLog->id,
                    'rule_id' => $ruleId,
                ]);
                $this->flagForHumanReview($ruleId, $reasoning);
                break;

            default:
                Log::warning('Unknown classification received', [
                    'chat_log_id' => $this->chatLog->id,
                    'classification' => $classification,
                ]);
                $this->flagForHumanReview($ruleId, "Unknown classification: {$classification}");
                break;
        }
    }

    protected function canAiEnforce(int $ruleId): bool
    {
        $rules = require app_path('Data/Rules.php');
        $rule = $rules[$ruleId] ?? null;

        if (! $rule) {
            Log::warning('Rule not found', [
                'chat_log_id' => $this->chatLog->id,
                'rule_id' => $ruleId,
                'available_rules' => array_keys($rules),
            ]);

            return false;
        }

        $nextEscalationLevel = Sanction::getNextEscalationLevel(
            $this->chatLog->steam_id,
            (string) $ruleId
        );

        $escalation = $rule['escalations'][$nextEscalationLevel] ?? null;

        if (! $escalation) {
            Log::warning('Escalation not found', [
                'chat_log_id' => $this->chatLog->id,
                'rule_id' => $ruleId,
                'escalation_level' => $nextEscalationLevel,
                'available_escalations' => array_keys($rule['escalations']),
            ]);

            return false;
        }

        $canEnforce = $escalation['is_ai_enforcable'] ?? false;

        Log::info('AI enforcement check result', [
            'chat_log_id' => $this->chatLog->id,
            'rule_id' => $ruleId,
            'escalation_level' => $nextEscalationLevel,
            'can_enforce' => $canEnforce,
            'escalation_details' => $escalation,
        ]);

        return $canEnforce;
    }

    protected function applyAutoSanction(int $ruleId, string $reasoning): void
    {
        DB::transaction(function () use ($ruleId, $reasoning) {
            $rules = require app_path('Data/Rules.php');
            $rule = $rules[$ruleId];

            $nextEscalationLevel = Sanction::getNextEscalationLevel(
                $this->chatLog->steam_id,
                (string) $ruleId
            );

            $escalation = $rule['escalations'][$nextEscalationLevel];

            // Determine sanction duration
            $expiresAt = null;
            if ($escalation['duration_in_minutes'] > 0) {
                $expiresAt = now()->addMinutes($escalation['duration_in_minutes']);
            }

            $reason = $escalation['reason_ai'] ?? $escalation['reason'];

            // Create the sanction
            Sanction::create([
                'steam_name' => $this->chatLog->steam_name,
                'steam_id' => $this->chatLog->steam_id,
                'character_name' => $this->chatLog->character_name,
                'character_id' => $this->chatLog->character_id,
                'ip_address' => $this->chatLog->ip_address,
                'type' => $escalation['type'],
                'reason' => $reason,
                'expires_at' => $expiresAt,
                'issued_by' => null, // null indicates AI-issued sanction
                'rule_id' => (string) $ruleId,
                'escalation_level' => $nextEscalationLevel,
                'chat_log_id' => $this->chatLog->id,
            ]);

            // Mark chat log as moderated
            $this->chatLog->update([
                'moderated_at' => now(),
                'moderated_by' => null, // null indicates AI moderation
                'flagged_at' => now(), // Flag so we can put the AI reasoning in that flag reason
                'flagged_reason' => "AI auto-sanctioned (Rule {$ruleId}): {$reasoning}",
            ]);

            Log::info('AI auto-sanction applied', [
                'chat_log_id' => $this->chatLog->id,
                'rule_id' => $ruleId,
                'sanction_type' => $escalation['type'],
                'steam_id' => $this->chatLog->steam_id,
            ]);
        });
    }

    protected function flagForHumanReview(?int $ruleId, string $reasoning): void
    {
        $flagReason = 'AI flagged for review';
        if ($ruleId) {
            $flagReason .= " (Rule {$ruleId})";
        }
        $flagReason .= ': '.$reasoning;

        $this->chatLog->update([
            'flagged_at' => now(),
            'flagged_reason' => $flagReason,
        ]);

        Log::info('Chat log flagged for human review', [
            'chat_log_id' => $this->chatLog->id,
            'rule_id' => $ruleId,
            'reasoning' => $reasoning,
        ]);
    }
}
