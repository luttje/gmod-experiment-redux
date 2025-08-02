<?php

namespace App\Livewire;

use App\Models\ChatLog;
use Jantinnerezo\LivewireAlert\LivewireAlert;
use Livewire\Component;
use Livewire\WithPagination;

class ChatLogModerationPage extends Component
{
    use LivewireAlert, WithPagination;

    public $showModerated = false;

    public $search = '';

    protected $queryString = [
        'search' => ['except' => ''],
        'showModerated' => ['except' => false],
        'page' => ['except' => 1],
    ];

    public function updatingSearch()
    {
        $this->resetPage();
    }

    public function updatingShowModerated()
    {
        $this->resetPage();
    }

    public function render()
    {
        $query = ChatLog::query();

        // Apply moderation filter
        if (! $this->showModerated) {
            $query->whereNull('moderated_at');
        }

        // Apply search filter
        if (! empty($this->search)) {
            $query->where(function ($q) {
                $q->where('character_name', 'like', '%'.$this->search.'%')
                    ->orWhere('message', 'like', '%'.$this->search.'%')
                    ->orWhere('chat_type', 'like', '%'.$this->search.'%');
            });
        }

        $chatLogs = $query->orderBy('flagged_at', 'desc')
            ->orderBy('created_at', 'desc')
            ->paginate(50);

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
     * Undo the moderation of a chat log.
     */
    public function undoModeration(ChatLog $chatLog)
    {
        $chatLog->update([
            'moderated_at' => null,
            'moderated_by' => null,
        ]);

        $this->alert('success', 'Chat log moderation has been undone.');
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
