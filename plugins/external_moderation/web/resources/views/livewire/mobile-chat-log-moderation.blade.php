<div class="min-h-screen bg-slate-800 text-white">
    <div class="sticky top-0 z-10 bg-slate-900 border-b border-slate-700 px-4 py-3">
        <div class="flex items-center justify-between">
            <h1 class="text-lg font-semibold">Chat Moderation</h1>
            <div class="text-sm text-slate-300">
                @if($totalCount > 0)
                    {{ $currentIndex + 1 }} / {{ $totalCount }}
                @endif
            </div>
        </div>

        @if($totalCount > 0)
            <div class="mt-2 bg-slate-700 rounded-full h-2">
                <div class="bg-blue-600 h-2 rounded-full transition-all duration-300"
                     style="width: {{ $totalCount > 0 ? (($currentIndex + 1) / $totalCount) * 100 : 0 }}%"></div>
            </div>
        @endif
    </div>

    <div class="mt-4">
        @if($showCompleted)
            <div class="text-center py-12">
                <div class="text-6xl mb-4">🎉</div>
                <h2 class="text-xl font-semibold mb-2">All done!</h2>
                <p class="text-slate-400 mb-6">No more chat logs to moderate.</p>
                <button wire:click="refreshLogs"
                        class="bg-blue-600 hover:bg-blue-700 px-6 py-2 rounded-lg font-medium transition-colors">
                    Check Again
                </button>
            </div>
        @elseif($currentChatLog)
            <div class="space-y-4">
                <!-- Chat Log Card -->
                <div class="bg-slate-700 rounded-lg p-4 space-y-3">
                    <!-- Header with flag and character info -->
                    <div class="flex items-start justify-between">
                        <div class="flex-1">
                            <div class="flex items-center gap-2 mb-1">
                                @if($currentChatLog->isFlagged())
                                    <span class="text-red-500 text-xl" title="Flagged">❗</span>
                                @endif
                                <h3 class="font-semibold text-lg">{{ $currentChatLog->character_name }}</h3>
                                @if($currentChatLog->rank)
                                    <span class="text-sm text-slate-400">({{ $currentChatLog->rank }})</span>
                                @endif
                            </div>
                            <div class="flex items-center gap-2 text-sm text-slate-400">
                                <span class="bg-slate-600 px-2 py-1 rounded text-xs">
                                    @if($currentChatLog->isVoiceChat())
                                        VOICE
                                    @else
                                        {{ strtoupper($currentChatLog->chat_type) }}
                                    @endif
                                </span>
                                <span>{{ $currentChatLog->created_at->diffForHumans() }}</span>
                            </div>
                        </div>
                    </div>

                    <!-- Message Content -->
                    <div class="bg-slate-600 rounded p-3">
                        @if($currentChatLog->isVoiceChat())
                            <div class="flex items-center justify-between">
                                <div class="flex-1">
                                    @if(empty($currentChatLog->message))
                                        <span class="text-slate-400 text-sm italic">Pending transcription...</span>
                                    @else
                                        <p class="mb-2">{{ $currentChatLog->message }}</p>
                                    @endif
                                </div>
                                <button wire:click="$wire.listen().then((url) => { if(url) { const audio = new Audio(url); audio.play(); } })"
                                        class="bg-emerald-600 hover:bg-emerald-700 p-2 rounded-full ml-3 transition-colors">
                                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                                        <path d="M8 5v14l11-7z"/>
                                    </svg>
                                </button>
                            </div>
                        @else
                            <p class="text-white">{{ $currentChatLog->message ?: 'No message content' }}</p>
                        @endif
                    </div>
                </div>

                <!-- Navigation Controls -->
                <div class="flex gap-2 mb-4">
                    <button wire:click="previous"
                            @if($currentIndex === 0) disabled @endif
                            class="flex-1 bg-slate-600 hover:bg-slate-500 disabled:bg-slate-700 disabled:text-slate-500 px-4 py-2 rounded-lg font-medium transition-colors">
                        ← Previous
                    </button>
                    <button wire:click="skip"
                            class="flex-1 bg-slate-600 hover:bg-slate-500 px-4 py-2 rounded-lg font-medium transition-colors">
                        Skip →
                    </button>
                </div>

                <!-- Action Buttons -->
                <div class="space-y-3">
                    <button wire:click="markSafe"
                            class="w-full bg-green-600 hover:bg-green-700 px-6 py-4 rounded-lg font-semibold text-lg transition-colors">
                        ✓ Mark as Safe
                    </button>

                    <a href="{{ route('sanctions.create', [
                        'chatLog' => $currentChatLog,
                        'back' => route('chat-logs.moderation.mobile', ['index' => $currentIndex ?? 0])
                    ]) }}"
                       class="block w-full bg-red-600 hover:bg-red-700 px-6 py-4 rounded-lg font-semibold text-lg text-center transition-colors">
                        🚨 Apply Sanction
                    </a>
                </div>

                <!-- Additional Info (Collapsible) -->
                <div class="mt-6">
                    <div x-data="{ showDetails: false }">
                        <button @click="showDetails = !showDetails"
                                class="w-full text-left text-slate-400 text-sm flex items-center justify-between py-2">
                            <span>Additional Details</span>
                            <svg class="w-4 h-4 transition-transform duration-200"
                                 :class="showDetails ? 'rotate-180' : ''"
                                 fill="currentColor" viewBox="0 0 24 24">
                                <path d="M7 10l5 5 5-5z"/>
                            </svg>
                        </button>
                        <div x-show="showDetails" class="bg-slate-700 rounded p-3 text-sm space-y-2">
                            <div><strong>Steam ID:</strong> {{ $currentChatLog->steam_id ?? 'N/A' }}</div>
                            <div><strong>Character ID:</strong> {{ $currentChatLog->character_id ?? 'N/A' }}</div>
                            <div><strong>IP Address:</strong> {{ $currentChatLog->ip_address ?? 'N/A' }}</div>
                            @if($currentChatLog->flagged_at)
                                <div><strong>Flagged:</strong> {{ $currentChatLog->flagged_at->diffForHumans() }}</div>
                            @endif
                        </div>
                    </div>
                </div>
            </div>
        @else
            <div class="text-center py-12">
                <div class="text-4xl mb-4">🔍</div>
                <h2 class="text-xl font-semibold mb-2">Loading...</h2>
                <p class="text-slate-400">Fetching chat logs to moderate...</p>
            </div>
        @endif
    </div>
</div>
