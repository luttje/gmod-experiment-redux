<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Sanction extends Model
{
    use HasFactory;

    protected $fillable = [
        'steam_name',
        'steam_id',
        'character_name',
        'character_id',
        'ip_address',
        'type',
        'reason',
        'expires_at',
        'issued_by',
        'rule_id',
        'escalation_level',
        'chat_log_id',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
        'anonymized_at' => 'datetime',
        'escalation_level' => 'integer',
    ];

    /**
     * Relationships
     */
    public function issuer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'issued_by');
    }

    public function chatLog(): BelongsTo
    {
        return $this->belongsTo(ChatLog::class);
    }

    /**
     * Check if the sanction is currently active
     */
    public function isActive(): bool
    {
        // TODO: Not used anymore, just ban 5 mins or fewer
        if ($this->type === 'kick') {
            return false; // Kicks are immediate and don't have duration
        }

        if (is_null($this->expires_at)) {
            return true; // Permanent sanction
        }

        return $this->expires_at->isFuture();
    }

    /**
     * Get the rule details if rule_id is set
     */
    public function getRuleDetails(): ?array
    {
        if (! $this->rule_id) {
            return null;
        }

        $rules = require app_path('Data/Rules.php');

        if (! isset($rules[$this->rule_id])) {
            return null;
        }

        $rule = $rules[$this->rule_id];
        $escalation = $rule['escalations'][$this->escalation_level] ?? null;

        return [
            'rule' => $rule,
            'escalation' => $escalation,
        ];
    }

    /**
     * Get sanctions for a specific player by steam_id
     */
    public static function getPlayerSanctions(string $steamId): \Illuminate\Database\Eloquent\Collection
    {
        return static::where('steam_id', $steamId)
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Get offense count for a specific rule and player
     */
    public static function getOffenseCount(string $steamId, string $ruleId): int
    {
        return static::where('steam_id', $steamId)
            ->where('rule_id', $ruleId)
            ->count();
    }

    /**
     * Get next escalation level for a rule and player
     */
    public static function getNextEscalationLevel(string $steamId, string $ruleId): int
    {
        $currentCount = static::getOffenseCount($steamId, $ruleId);

        $rules = require app_path('Data/Rules.php');
        $rule = $rules[$ruleId] ?? null;

        if (! $rule) {
            return 0;
        }

        // Return the next escalation level, or the highest available if we've exceeded
        $maxLevel = count($rule['escalations']) - 1;

        return min($currentCount, $maxLevel);
    }
}
