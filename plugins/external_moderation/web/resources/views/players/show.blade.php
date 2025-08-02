<x-layouts.app>
    <header>
        <div class="flex justify-between items-center mb-6">
            <h2 class="font-semibold text-xl leading-tight">
                {{ __('Player Profile') }}
            </h2>
            <div class="flex gap-2">
                <!-- Sanction Button -->
                <x-primary-button href="{{ route('sanctions.create-for-player', $player->steam_id) }}"
                    target="_blank">
                    Sanction
                </x-primary-button>
                <x-primary-button href="{{ route('sanctions.index') }}">
                    Back to Sanctions
                </x-primary-button>
            </div>
        </div>
    </header>

    <div class="bg-slate-800 overflow-hidden shadow-sm sm:rounded-lg">
        <!-- Player Status Banner -->
        <div class="mb-6 p-4 rounded-lg border-l-4
            @if($stats['active_sanctions'] > 0)
                bg-red-900/30 border-red-500
            @elseif($stats['total_sanctions'] > 0)
                bg-yellow-900/30 border-yellow-500
            @else
                bg-green-900/30 border-green-500
            @endif">
            <div class="flex items-center justify-between">
                <div class="flex items-center gap-3">
                    @if($stats['active_sanctions'] > 0)
                        <span class="px-3 py-1 rounded-full text-sm font-medium bg-red-600 text-red-100">
                            {{ $stats['active_sanctions'] }} ACTIVE SANCTION{{ $stats['active_sanctions'] > 1 ? 'S' : '' }}
                        </span>
                    @elseif($stats['total_sanctions'] > 0)
                        <span class="px-3 py-1 rounded-full text-sm font-medium bg-yellow-600 text-yellow-100">
                            SANCTIONED PLAYER
                        </span>
                    @else
                        <span class="px-3 py-1 rounded-full text-sm font-medium bg-green-600 text-green-100">
                            CLEAN RECORD
                        </span>
                    @endif

                    @if($player->anonymized_at)
                        <span class="px-3 py-1 rounded-full text-xs font-medium bg-purple-600 text-purple-100">
                            ANONYMIZED
                        </span>
                    @endif
                </div>
                <div class="text-right text-sm text-gray-300">
                    @if($stats['last_seen'])
                        <div>Last Seen: {{ $stats['last_seen']->format('M j, Y \a\t g:i A') }}</div>
                        <div>{{ $stats['last_seen']->diffForHumans() }}</div>
                    @endif
                </div>
            </div>
        </div>

        <!-- Player Information -->
        <div class="mb-6 p-4 bg-slate-700 rounded-lg">
            <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"></path>
                </svg>
                Player Information
            </h3>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-400 mb-1">Steam Name</label>
                    <div class="text-white font-medium">{{ $player->steam_name }}</div>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-400 mb-1">Steam ID</label>
                    <div class="text-white font-mono">{{ $player->steam_id }}</div>
                </div>
                @if($player->character_name)
                    <div>
                        <label class="block text-sm font-medium text-gray-400 mb-1">Character Name</label>
                        <div class="text-white font-medium">{{ $player->character_name }}</div>
                    </div>
                @endif
                @if($player->character_id)
                    <div>
                        <label class="block text-sm font-medium text-gray-400 mb-1">Character ID</label>
                        <div class="text-white">{{ $player->character_id }}</div>
                    </div>
                @endif
                @if($player->rank && $player->rank !== 'player')
                    <div>
                        <label class="block text-sm font-medium text-gray-400 mb-1">Rank</label>
                        <div class="text-white capitalize">{{ $player->rank }}</div>
                    </div>
                @endif
                @if($stats['first_seen'])
                    <div>
                        <label class="block text-sm font-medium text-gray-400 mb-1">First Seen</label>
                        <div class="text-white">{{ $stats['first_seen']->format('M j, Y') }}</div>
                        <div class="text-sm text-gray-400">{{ $stats['first_seen']->diffForHumans() }}</div>
                    </div>
                @endif
            </div>
        </div>

        <!-- Statistics Overview -->
        <div class="mb-6 p-4 bg-slate-700 rounded-lg">
            <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                    <path d="M2 11a1 1 0 011-1h2a1 1 0 011 1v5a1 1 0 01-1 1H3a1 1 0 01-1-1v-5zM8 7a1 1 0 011-1h2a1 1 0 011 1v9a1 1 0 01-1 1H9a1 1 0 01-1-1V7zM14 4a1 1 0 011-1h2a1 1 0 011 1v12a1 1 0 01-1 1h-2a1 1 0 01-1-1V4z"></path>
                </svg>
                Statistics Overview
            </h3>
            <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                <div class="text-center">
                    <div class="text-2xl font-bold text-white">{{ $stats['total_sanctions'] }}</div>
                    <div class="text-sm text-gray-400">Total Sanctions</div>
                </div>
                <div class="text-center">
                    <div class="text-2xl font-bold
                        @if($stats['active_sanctions'] > 0) text-red-400
                        @else text-green-400
                        @endif">
                        {{ $stats['active_sanctions'] }}
                    </div>
                    <div class="text-sm text-gray-400">Active Sanctions</div>
                </div>
                <div class="text-center">
                    <div class="text-2xl font-bold text-white">{{ $stats['total_chat_messages'] }}</div>
                    <div class="text-sm text-gray-400">Chat Messages</div>
                </div>
                <div class="text-center">
                    <div class="text-2xl font-bold
                        @if($stats['flagged_messages'] > 0) text-yellow-400
                        @else text-green-400
                        @endif">
                        {{ $stats['flagged_messages'] }}
                    </div>
                    <div class="text-sm text-gray-400">Flagged Messages</div>
                </div>
                <div class="text-center">
                    <div class="text-2xl font-bold text-white">{{ $stats['recent_sanctions_30d'] }}</div>
                    <div class="text-sm text-gray-400">Sanctions (30d)</div>
                </div>
                <div class="text-center">
                    <div class="text-lg font-bold text-white">
                        @if($stats['time_since_last_sanction'])
                            {{ $stats['time_since_last_sanction'] }}
                        @else
                            N/A
                        @endif
                    </div>
                    <div class="text-sm text-gray-400">Last Sanction</div>
                </div>
            </div>
        </div>

        <!-- Sanction Type Breakdown -->
        @if($stats['sanction_types']->count() > 0)
            <div class="mb-6 p-4 bg-slate-700 rounded-lg">
                <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M3 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1zm0 4a1 1 0 011-1h12a1 1 0 110 2H4a1 1 0 01-1-1z" clip-rule="evenodd"></path>
                    </svg>
                    Sanction Type Breakdown
                </h3>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    @foreach($stats['sanction_types'] as $type => $count)
                        <div class="flex items-center justify-between p-3 bg-slate-600 rounded">
                            <div class="flex items-center gap-2">
                                <span class="px-2 py-1 rounded text-xs font-medium
                                    @if($type === 'mute') bg-yellow-600
                                    @elseif($type === 'kick') bg-orange-600
                                    @elseif($type === 'ban') bg-red-600
                                    @endif">
                                    {{ strtoupper($type) }}
                                </span>
                            </div>
                            <div class="text-white font-bold">{{ $count }}</div>
                        </div>
                    @endforeach
                </div>
            </div>
        @endif

        <!-- Rule Violations -->
        @if(count($ruleViolations) > 0)
            <div class="mb-6 p-4 bg-slate-700 rounded-lg">
                <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 64 64">
                        <g>
                            <circle cx="50" cy="21.014" r="2"/>
                            <path d="M62.838,17.992L46.021,1.175c-1.55-1.548-4.057-1.548-5.606,0l-2.102,2.104l4.204,4.203
                                c0.388,0.387,0.388,1.015,0,1.401c-0.388,0.389-1.015,0.389-1.401,0l-4.204-4.204l-2.804,2.803l7.008,7.007
                                c0.387,0.388,0.387,1.015,0,1.402c-0.388,0.387-1.015,0.387-1.401,0l-7.007-7.006l-2.803,2.802l4.203,4.204
                                c0.388,0.387,0.388,1.014,0,1.4c-0.387,0.388-1.014,0.388-1.4,0l-4.204-4.203L25.7,15.891l4.205,4.203
                                c0.387,0.388,0.387,1.014,0,1.402c-0.388,0.389-1.015,0.389-1.401-0.001l-4.205-4.204l-2.803,2.805l7.008,7.006
                                c0.387,0.388,0.387,1.014,0,1.402c-0.389,0.387-1.015,0.387-1.402,0l-7.006-7.008l-2.804,2.803l4.204,4.204
                                c0.388,0.388,0.388,1.015,0,1.402c-0.389,0.387-1.015,0.387-1.401,0L15.891,25.7l-2.803,2.804l4.204,4.204
                                c0.387,0.386,0.387,1.013,0,1.4c-0.388,0.388-1.015,0.388-1.401,0l-4.204-4.203l-2.803,2.803l7.007,7.007
                                c0.387,0.387,0.387,1.014,0,1.401c-0.388,0.387-1.015,0.387-1.402,0l-7.006-7.008l-2.804,2.804l4.204,4.204
                                c0.389,0.387,0.389,1.015,0.001,1.401c-0.389,0.387-1.016,0.387-1.401,0l-4.204-4.204l-2.104,2.102
                                c-1.549,1.549-1.549,4.056,0,5.606l16.817,16.816c1.549,1.55,4.057,1.55,5.606,0l39.24-39.239
                                C64.388,22.049,64.388,19.541,62.838,17.992z M50,25.014c-2.209,0-4-1.791-4-4s1.791-4,4-4s4,1.791,4,4S52.209,25.014,50,25.014z"
                                />
                        </g>
                    </svg>
                    Rule Violation History
                </h3>
                <div class="space-y-3">
                    @foreach($ruleViolations as $ruleId => $violation)
                        <div class="bg-slate-600 p-4 rounded">
                            <div class="flex justify-between items-start mb-2">
                                <div class="flex-1">
                                    <h4 class="font-medium text-white">{{ $violation['rule']['title'] }}</h4>
                                    <p class="text-sm text-gray-300 mt-1">{{ $violation['rule']['description'] }}</p>
                                </div>
                                <div class="text-right ml-4">
                                    <div class="text-lg font-bold text-red-400">{{ $violation['total_violations'] }}</div>
                                    <div class="text-xs text-gray-400">violations</div>
                                </div>
                            </div>
                            <div class="flex items-center justify-between text-sm">
                                <div class="text-gray-400">
                                    Escalation levels: {{ implode(', ', array_unique($violation['escalation_levels'])) }}
                                </div>
                                <div class="text-gray-400">
                                    Last: {{ $violation['last_violation']->format('M j, Y') }}
                                </div>
                            </div>
                        </div>
                    @endforeach
                </div>
            </div>
        @endif

        <!-- Recent Sanctions -->
        @if($sanctions->count() > 0)
            <div class="mb-6 p-4 bg-slate-700 rounded-lg">
                <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3zm11.707 4.707a1 1 0 00-1.414-1.414L10 9.586 8.707 8.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                    </svg>
                    Sanction History ({{ $sanctions->count() }})
                </h3>
                <div class="space-y-2 max-h-80 overflow-y-auto">
                    @foreach($sanctions->take(20) as $sanction)
                        <div class="bg-slate-600 p-3 rounded flex justify-between items-start">
                            <div class="flex-1">
                                <div class="flex items-center gap-2 mb-1">
                                    <span class="px-2 py-1 rounded text-xs font-medium
                                        @if($sanction->type === 'mute') bg-yellow-600
                                        @elseif($sanction->type === 'kick') bg-orange-600
                                        @elseif($sanction->type === 'ban') bg-red-600
                                        @endif">
                                        {{ strtoupper($sanction->type) }}
                                    </span>
                                    <span class="px-2 py-1 rounded text-xs font-medium
                                        @if($sanction->isActive()) bg-red-600
                                        @else bg-gray-600
                                        @endif">
                                        @if($sanction->isActive()) ACTIVE
                                        @else EXPIRED
                                        @endif
                                    </span>
                                </div>
                                <div class="text-sm">{{ Str::limit($sanction->reason, 100) }}</div>
                                @if($sanction->expires_at)
                                    <div class="text-xs text-gray-400 mt-1">
                                        @if($sanction->isActive())
                                            Expires: {{ $sanction->expires_at->diffForHumans() }}
                                        @else
                                            Expired: {{ $sanction->expires_at->diffForHumans() }}
                                        @endif
                                    </div>
                                @else
                                    <div class="text-xs text-red-400 mt-1">Permanent</div>
                                @endif
                            </div>
                            <div class="text-xs text-right ml-4">
                                <div>{{ $sanction->created_at->format('M j, Y') }}</div>
                                <a href="{{ route('sanctions.show', $sanction) }}"
                                   class="text-blue-400 hover:text-blue-300 underline">
                                    View Details
                                </a>
                            </div>
                        </div>
                    @endforeach

                    @if($sanctions->count() > 20)
                        <div class="text-center text-gray-400 text-sm py-2">
                            Showing 20 of {{ $sanctions->count() }} sanctions
                        </div>
                    @endif
                </div>
            </div>
        @endif

        <!-- Flagged Chat Messages -->
        @if($flaggedChatLogs->count() > 0)
            <div class="mb-6 p-4 bg-slate-700 rounded-lg">
                <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path>
                    </svg>
                    Flagged Messages ({{ $flaggedChatLogs->count() }})
                </h3>
                <div class="space-y-2 max-h-60 overflow-y-auto">
                    @foreach($flaggedChatLogs->take(10) as $chatLog)
                        <div class="bg-red-900/30 border border-red-600 p-3 rounded">
                            <div class="flex justify-between items-start mb-2">
                                <div class="text-xs text-gray-400">
                                    {{ $chatLog->created_at->format('M j, Y g:i A') }} -
                                    {{ strtoupper($chatLog->chat_type) }}
                                </div>
                                @if($chatLog->moderated_at)
                                    <span class="px-2 py-1 rounded text-xs font-medium bg-green-600 text-green-100">
                                        MODERATED
                                    </span>
                                @else
                                    <span class="px-2 py-1 rounded text-xs font-medium bg-yellow-600 text-yellow-100">
                                        PENDING
                                    </span>
                                @endif
                            </div>
                            @if($chatLog->message)
                                <div class="text-white mb-2">{{ $chatLog->message }}</div>
                            @endif
                            <div class="text-sm text-red-300">
                                <strong>Flagged:</strong> {{ $chatLog->flagged_reason }}
                            </div>
                        </div>
                    @endforeach

                    @if($flaggedChatLogs->count() > 10)
                        <div class="text-center text-gray-400 text-sm py-2">
                            Showing 10 of {{ $flaggedChatLogs->count() }} flagged messages
                        </div>
                    @endif
                </div>
            </div>
        @endif

        <!-- Recent Chat Activity -->
        @if($chatLogs->count() > 0)
            <div class="mb-6 p-4 bg-slate-700 rounded-lg">
                <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M18 13V5a2 2 0 00-2-2H4a2 2 0 00-2 2v8a2 2 0 002 2h3l3 3 3-3h3a2 2 0 002-2zM5 7a1 1 0 011-1h8a1 1 0 110 2H6a1 1 0 01-1-1zm1 3a1 1 0 100 2h3a1 1 0 100-2H6z" clip-rule="evenodd"></path>
                    </svg>
                    Recent Chat Activity ({{ $chatLogs->count() }} messages)
                </h3>
                <div class="space-y-2 max-h-60 overflow-y-auto">
                    @foreach($chatLogs->take(15) as $chatLog)
                        <div class="bg-slate-600 p-3 rounded
                            @if($chatLog->flagged_reason) border-l-4 border-red-500 @endif">
                            <div class="flex justify-between items-start mb-1">
                                <div class="text-xs text-gray-400">
                                    {{ $chatLog->created_at->format('M j, Y g:i A') }} -
                                    {{ strtoupper($chatLog->chat_type) }}
                                    @if($chatLog->isVoiceChat())
                                        (Voice Chat)
                                    @endif
                                </div>
                                @if($chatLog->flagged_reason)
                                    <span class="px-2 py-1 rounded text-xs font-medium bg-red-600 text-red-100">
                                        FLAGGED
                                    </span>
                                @endif
                            </div>
                            @if($chatLog->message)
                                <div class="text-white text-sm">{{ Str::limit($chatLog->message, 150) }}</div>
                            @else
                                <div class="text-gray-400 text-sm italic">Voice message (no transcription)</div>
                            @endif
                        </div>
                    @endforeach

                    @if($chatLogs->count() > 15)
                        <div class="text-center text-gray-400 text-sm py-2">
                            Showing 15 of {{ $chatLogs->count() }} recent messages
                        </div>
                    @endif
                </div>
            </div>
        @endif

        <!-- No Data Message -->
        @if($sanctions->count() === 0 && $chatLogs->count() === 0)
            <div class="p-8 text-center">
                <svg class="w-16 h-16 mx-auto text-gray-400 mb-4" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                </svg>
                <h3 class="text-lg font-medium text-white mb-2">No Activity Found</h3>
                <p class="text-gray-400">This player has no recorded sanctions or chat activity.</p>
            </div>
        @endif
    </div>
</x-layouts.app>
