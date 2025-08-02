<?php

namespace App\Livewire;

use App\Models\ChatLog;
use Jantinnerezo\LivewireAlert\LivewireAlert;
use Livewire\Attributes\Url;
use Livewire\Component;

class MobileChatLogModeration extends Component
{
    use LivewireAlert;

    public $currentChatLog;

    #[Url(as: 'index')]
    public $currentIndex = 0;

    public $totalCount = 0;

    public $showCompleted = false;

    public function mount()
    {
        $this->loadNext();
    }

    public function render()
    {
        return view('livewire.mobile-chat-log-moderation');
    }

    public function loadNext()
    {
        $query = ChatLog::whereNull('moderated_at')
            ->orderBy('flagged_at', 'desc')
            ->orderBy('created_at', 'desc');

        $this->totalCount = $query->count();

        if ($this->totalCount === 0) {
            $this->currentChatLog = null;
            $this->showCompleted = true;

            return;
        }

        $this->currentChatLog = $query->skip($this->currentIndex)->first();

        if (! $this->currentChatLog) {
            $this->showCompleted = true;
        }
    }

    public function markSafe()
    {
        if (! $this->currentChatLog) {
            return;
        }

        if ($this->currentChatLog->isVoiceChat()) {
            $voicePath = realpath($this->currentChatLog->voice_chat_path);
            if ($voicePath) {
                unlink($voicePath);
            }
        }

        $this->currentChatLog->update([
            'moderated_at' => now(),
            'moderated_by' => auth()->id(),
        ]);

        $this->alert('success', 'Marked as safe');
        $this->loadNext();
    }

    public function skip()
    {
        $this->currentIndex++;
        $this->loadNext();
    }

    public function previous()
    {
        if ($this->currentIndex > 0) {
            $this->currentIndex--;
            $this->loadNext();
        }
    }

    public function refreshLogs()
    {
        $this->currentIndex = 0;
        $this->showCompleted = false;
        $this->loadNext();
    }

    public function listen()
    {
        if (! $this->currentChatLog || ! $this->currentChatLog->isVoiceChat()) {
            return;
        }

        $voicePath = realpath($this->currentChatLog->voice_chat_path);
        if (! $voicePath) {
            $this->alert('error', 'Voice chat file not found.');

            return null;
        }

        return route('play-audio', $this->currentChatLog);
    }
}
