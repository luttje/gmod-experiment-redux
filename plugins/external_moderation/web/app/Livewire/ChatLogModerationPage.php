<?php

namespace App\Livewire;

use App\Models\ChatLog;
use Illuminate\Support\Facades\Storage;
use Jantinnerezo\LivewireAlert\LivewireAlert;
use Livewire\Component;

class ChatLogModerationPage extends Component
{
    use LivewireAlert;

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
    public function markSafe(ChatLog $chatLog)
    {
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

    /**
     * Play audio for voice chat
     */
    public function listen(ChatLog $chatLog)
    {
        $voicePath = realpath($chatLog->voice_chat_path);

        if (! $voicePath) {
            $this->alert('error', 'Voice chat file not found. It may have been deleted to save disk space.');

            return;
        }

        return route('play-audio', $chatLog);
    }
}
