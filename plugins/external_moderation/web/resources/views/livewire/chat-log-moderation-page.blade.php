<div>
    <x-slot name="title">
        Chat Logs
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
        <p>
            This is a list of all chat logs that have yet to be moderated.
        </p>
        <x-navigation-button href="{{ route('chat-logs.moderation.mobile') }}">
            Switch to Mobile Moderation View
        </x-navigation-button>
    </section>

    <section class="rounded bg-slate-700 p-4 flex flex-col gap-4"
             x-data="{
            volume: 1,
            isPlayingAudio: false,
            audioPlayer: null,
            playAudio: function (url) {
                if (this.isPlayingAudio) {
                    return;
                }

                this.isPlayingAudio = true;

                this.audioPlayer = new Audio(url);
                this.audioPlayer.volume = this.volume;
                this.audioPlayer.play();

                this.audioPlayer.addEventListener('ended', () => {
                    this.isPlayingAudio = false;
                });
            },
            stopAudio: function () {
                if (this.audioPlayer) {
                    this.audioPlayer.pause();
                    this.isPlayingAudio = false;
                }
            },
        }">
        <div class="fixed bottom-0 right-0 p-4 bg-slate-800 rounded shadow-lg">
            <div class="flex gap-4 items-center">
                <button @click="stopAudio()"
                        class="text-red-600">
                    <svg class="w-6 h-6"
                         fill="none"
                         stroke="currentColor"
                         viewBox="0 0 24 24"
                         xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round"
                              stroke-linejoin="round"
                              stroke-width="2"
                              d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
                <input type="range"
                       min="0"
                       max="1"
                       step="0.01"
                       value="1"
                       x-model="volume"
                       class="w-32">
            </div>
        </div>

        <h2 class="text-2xl font-bold">
            Chat Logs
        </h2>

        <!-- Filters Section -->
        <div class="flex flex-col md:flex-row gap-4 mb-4">
            <!-- Search Bar -->
            <div class="flex-1">
                <label for="search" class="block text-sm font-medium text-gray-300 mb-1">Search</label>
                <input type="text"
                       id="search"
                       wire:model.live.debounce.300ms="search"
                       placeholder="Search by character name, message, or type..."
                       class="w-full px-3 py-2 bg-slate-600 border border-slate-500 rounded-md text-white placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent">
            </div>

            <!-- Show Moderated Checkbox -->
            <div class="flex items-end">
                <label class="flex items-center space-x-2 text-gray-300">
                    <input type="checkbox"
                           wire:model.live="showModerated"
                           class="w-4 h-4 text-blue-600 bg-slate-600 border-slate-500 rounded focus:ring-blue-500 focus:ring-2">
                    <span class="text-sm">Show already moderated logs</span>
                </label>
            </div>
        </div>

        <!-- Results Summary -->
        <div class="text-sm text-gray-400">
            @if(!empty($search) || $showModerated)
                <span>
                    Showing
                    @if(!empty($search))
                        results for "<strong>{{ $search }}</strong>"
                    @endif
                    @if($showModerated)
                        @if(!empty($search)) and @endif
                        <strong>including moderated logs</strong>
                    @endif
                </span>
            @endif
        </div>

        <x-table>
            <x-slot name="head">
                <x-table.heading>

                </x-table.heading>
                <x-table.heading>
                    Character Name
                </x-table.heading>
                <x-table.heading>
                    Type
                </x-table.heading>
                <x-table.heading>
                    Message
                </x-table.heading>
                <x-table.heading>
                    Received
                </x-table.heading>
                <x-table.heading>
                    Status
                </x-table.heading>
                <x-table.heading class="text-right">
                    Actions
                </x-table.heading>
            </x-slot>

            <x-slot name="body">
                @forelse ($chatLogs as $chatLog)
                <x-table.row :even="$loop->even"
                             wire:key="chat-log-{{ $chatLog->id }}">
                    <x-table.cell class="w-0 pr-0">
                        @if ($chatLog->isFlagged())
                        <span class="text-red-600 text-bold"
                              title="Flagged">❗</span>
                        @endif
                    </x-table.cell>
                    <x-table.cell>
                        {{ $chatLog->character_name }}
                    </x-table.cell>
                    <x-table.cell class="text-xs">
                        @if ($chatLog->isVoiceChat())
                        <a class="text-emerald-600"
                           @click="$wire.listen('{{ $chatLog->id }}').then((url) => { url ? playAudio(url) : void(0); })"
                           href="javascript:void(0)">(Voice)</a>
                        @else
                        ({{ strtoupper($chatLog->chat_type) }})
                        @endif
                    </x-table.cell>
                    <x-table.cell>
                        @if (empty($chatLog->message))
                        <span class="text-gray-400 text-xs">Pending transcription...</span>
                        @else
                        {{ $chatLog->message }}
                        @endif
                    </x-table.cell>
                    <x-table.cell>
                        {{ $chatLog->created_at->diffForHumans() }}
                    </x-table.cell>
                    <x-table.cell>
                        @if($chatLog->moderated_at)
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-center whitespace-nowrap text-xs font-medium bg-green-100 text-green-800">
                            Moderated {{ $chatLog->moderated_at->diffForHumans() }}
                        </span>
                        @else
                        <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                            Pending
                        </span>
                        @endif
                    </x-table.cell>
                    <x-table.cell class="flex gap-2 justify-end">
                        @if(!$chatLog->moderated_at)
                        <!-- Sanction Button -->
                        <x-primary-button href="{{ route('sanctions.create', $chatLog) }}"
                            target="_blank">
                            Sanction
                        </x-primary-button>

                        <!-- Mark Safe Button -->
                        <x-primary-button
                                wire:click="markSafe('{{ $chatLog->id }}')"
                                wire:confirm="Are you sure you want to mark this chat log as safe?">
                            Mark Safe
                        </x-primary-button>
                        @else
                        <span class="text-gray-400 text-sm">
                            @foreach ($chatLog->sanctions as $sanction)
                            <x-primary-button href="{{ route('sanctions.show', $sanction) }}"
                               target="_blank">
                                View '{{ $sanction->type }}' Sanction
                            </x-primary-button>
                            @endforeach
                        </span>

                        {{-- <!-- Undo Moderation Button -->
                        <x-primary-button
                                wire:click="undoModeration('{{ $chatLog->id }}')"
                                wire:confirm="Are you sure you want to undo moderation for this chat log?">
                            Undo Moderation
                        </x-primary-button> --}}
                        @endif
                    </x-table.cell>
                </x-table.row>
                @empty
                <x-table.row>
                    <x-table.cell colspan="7" class="text-center text-gray-400 py-8">
                        @if(!empty($search))
                            No chat logs found matching your search criteria.
                        @elseif($showModerated)
                            No chat logs found.
                        @else
                            No unmoderated chat logs found.
                        @endif
                    </x-table.cell>
                </x-table.row>
                @endforelse
            </x-slot>
        </x-table>

        <div>
            {{ $chatLogs->links() }}
        </div>
    </section>
</div>
