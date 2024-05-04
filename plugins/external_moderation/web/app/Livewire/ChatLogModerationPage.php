<?php

namespace App\Livewire;

use App\Models\ChatLog;
use App\Models\Sanction;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Jantinnerezo\LivewireAlert\LivewireAlert;
use Livewire\Component;

class ChatLogModerationPage extends Component
{
    use LivewireAlert;

    public string $type = '';
    public string $reason;
    public ?string $expires_at;

    public function mount()
    {
        $this->expires_at = now()->addHour()->format('Y-m-d\TH:i');
    }

    public function render()
    {
        $chatLogs = ChatLog::query()
            ->whereNull('moderated_at')
            ->orderBy('flagged_at', 'desc')
            ->paginate(100);

        return view('livewire.chat-log-moderation-page', compact('chatLogs'));
    }

    /**
     * Update the specified resource moderation in storage.
     */
    public function moderate(ChatLog $chatLog, $action = 'mark-safe')
    {
        if ($action !== 'sanction' && $action !== 'mark-safe') {
            $this->alert('error', 'Invalid action.');
            return;
        }

        if ($action === 'sanction') {
            $this->validate([
                'type' => 'required|in:mute,kick,ban',
                'reason' => 'required|string',
                'expires_at' => 'nullable|date',
            ]);

            return DB::transaction(function () use ($chatLog) {
                $chatLog->update([
                    'moderated_at' => now(),
                    'moderated_by' => auth()->id(),
                ]);

                Sanction::create([
                    'steam_name' => $chatLog->steam_name,
                    'steam_id' => $chatLog->steam_id,
                    'character_name' => $chatLog->character_name,
                    'character_id' => $chatLog->character_id,
                    'ip_address' => $chatLog->ip_address,

                    'type' => $this->type,
                    'reason' => $this->reason,
                    'expires_at' => $this->expires_at,
                    'issued_by' => auth()->id(),
                ]);

                $this->alert('success', 'Chat log has been sanctioned.');
            });
        }

        if ($chatLog->isVoiceChat()) {
            $voicePath = realpath($chatLog->voice_chat_path);

            if ($voicePath) {
                // Remove the voice chat file to save space
                unlink($voicePath);
            }
        }

        $chatLog->update([
            'moderated_at' => now(),
            'moderated_by' => auth()->id(),
        ]);

        $this->alert('success', 'Chat log has been marked safe.');
    }

    public function listen(ChatLog $chatLog)
    {
        $voicePath = realpath($chatLog->voice_chat_path);

        if (!$voicePath) {
            $this->alert('error', 'Voice chat file not found. It may have been deleted to save disk space.');
            return;
        }

        return route('play-audio', $chatLog);
    }
}
