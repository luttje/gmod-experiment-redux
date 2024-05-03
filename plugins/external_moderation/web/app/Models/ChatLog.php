<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ChatLog extends Model
{
    use HasFactory;

    protected $fillable = [
        'moderated_at',
        'moderated_by',
    ];

    public function isVoiceChat(): bool
    {
        return ! is_null($this->voice_chat_path);
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
