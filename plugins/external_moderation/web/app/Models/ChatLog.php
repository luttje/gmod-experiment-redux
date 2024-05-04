<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChatLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'chat_type',
        'steam_id',
        'steam_name',
        'character_id',
        'character_name',
        'ip_address',
        'message',
        'voice_chat_path',
        'moderated_at',
        'moderated_by',
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
     *
     * Relationships
     *
     */

}
