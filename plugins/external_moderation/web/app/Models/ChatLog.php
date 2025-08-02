<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ChatLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'chat_type',
        'steam_id',
        'steam_name',
        'rank',
        'character_id',
        'character_name',
        'ip_address',
        'message',
        'voice_chat_path',
        'moderated_at',
        'moderated_by',
        'flagged_at',
        'flagged_reason',
    ];

    protected $casts = [
        'moderated_at' => 'datetime',
        'flagged_at' => 'datetime',
        'anonymized_at' => 'datetime',
    ];

    public function isVoiceChat(): bool
    {
        return $this->chat_type === 'voice';
    }

    public function isFlagged(): bool
    {
        return ! is_null($this->flagged_at);
    }

    /**
     * Relationships
     */
    public function sanctions(): HasMany
    {
        return $this->hasMany(Sanction::class);
    }
}
