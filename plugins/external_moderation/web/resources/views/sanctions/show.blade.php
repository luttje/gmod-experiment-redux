<x-layouts.app>
    <header>
        <div class="flex justify-between items-center mb-6">
            <h2 class="font-semibold text-xl leading-tight">
                {{ __('Sanction Details') }}
            </h2>
            <div class="flex gap-2">
                @if($sanction->isActive())
                    <form method="POST" action="{{ route('sanctions.revoke', $sanction) }}" class="inline">
                        @csrf
                        @method('PATCH')
                        <button type="submit"
                                onclick="return confirm('Are you sure you want to revoke this sanction?')"
                                class="px-4 py-2 bg-yellow-600 text-white rounded hover:bg-yellow-700 text-sm font-medium">
                            Revoke Sanction
                        </button>
                    </form>
                @endif
                <x-primary-button href="{{ route('sanctions.index') }}">
                    Back to Sanctions
                </x-primary-button>
            </div>
        </div>
    </header>

    <div class="bg-slate-800 overflow-hidden shadow-sm sm:rounded-lg">
            <!-- Sanction Status Banner -->
            <div class="mb-6 p-4 rounded-lg border-l-4
                @if($sanction->isActive())
                    bg-red-900/30 border-red-500
                @else
                    bg-gray-900/30 border-gray-500
                @endif">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-3">
                        <span class="px-3 py-1 rounded-full text-sm font-medium
                            @if($sanction->type === 'mute') bg-yellow-600 text-yellow-100
                            @elseif($sanction->type === 'kick') bg-orange-600 text-orange-100
                            @elseif($sanction->type === 'ban') bg-red-600 text-red-100
                            @endif">
                            {{ strtoupper($sanction->type) }}
                        </span>
                        <span class="px-3 py-1 rounded-full text-xs font-medium
                            @if($sanction->isActive()) bg-red-600 text-red-100
                            @else bg-gray-600 text-gray-100
                            @endif">
                            @if($sanction->isActive())
                                ACTIVE
                            @else
                                EXPIRED
                            @endif
                        </span>
                    </div>
                    <div class="text-right text-sm text-gray-300">
                        <div>Sanction ID: #{{ $sanction->id }}</div>
                        <div>{{ $sanction->created_at->format('M j, Y \a\t g:i A') }}</div>
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
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-400 mb-1">Character Name</label>
                        <div class="text-white font-medium">{{ $sanction->character_name }}</div>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-400 mb-1">Steam Name</label>
                        <div class="text-white font-medium">{{ $sanction->steam_name }}</div>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-400 mb-1">Steam ID</label>
                        <div class="flex flex-row gap-2">
                            <div class="text-white font-mono">{{ $sanction->steam_id }}</div>
                            <x-primary-button class="text-white font-mono"
                                href="{{ route('players.show', $sanction->steam_id) }}">
                                View More
                            </x-primary-button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Sanction Details -->
            <div class="mb-6 p-4 bg-slate-700 rounded-lg">
                <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                    <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                        <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path>
                    </svg>
                    Sanction Details
                </h3>
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-400 mb-1">Reason</label>
                        <div class="bg-slate-600 p-3 rounded text-white">
                            {{ $sanction->reason }}
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Applied Date</label>
                            <div class="text-white">{{ $sanction->created_at->format('M j, Y \a\t g:i A T') }}</div>
                            <div class="text-sm text-gray-400">{{ $sanction->created_at->diffForHumans() }}</div>
                        </div>

                        @if($sanction->expires_at)
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">
                                    @if($sanction->isActive())
                                        Expires Date
                                    @else
                                        Expired Date
                                    @endif
                                </label>
                                <div class="text-white">{{ $sanction->expires_at->format('M j, Y \a\t g:i A T') }}</div>
                                <div class="text-sm
                                    @if($sanction->isActive()) text-yellow-400
                                    @else text-gray-400
                                    @endif">
                                    {{ $sanction->expires_at->diffForHumans() }}
                                </div>
                            </div>
                        @else
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">Duration</label>
                                <div class="text-red-400 font-medium">Permanent</div>
                            </div>
                        @endif
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Issued By</label>
                            <div class="text-white">
                                @if($sanction->issued_by)
                                    {{ $sanction->issuer->name }}
                                    <span class="text-gray-400 text-sm">(Staff)</span>
                                @else
                                    <span class="italic text-gray-400">Automated System</span>
                                @endif
                            </div>
                        </div>

                        @if($sanction->revoked_at)
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">Revoked Date</label>
                                <div class="text-yellow-400">{{ $sanction->revoked_at->format('M j, Y \a\t g:i A T') }}</div>
                                <div class="text-sm text-gray-400">{{ $sanction->revoked_at->diffForHumans() }}</div>
                            </div>
                        @endif
                    </div>

                    @if($sanction->revoked_by)
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Revoked By</label>
                            <div class="text-yellow-400">{{ $sanction->revoker->name }}</div>
                        </div>
                    @endif

                    @if($sanction->revocation_reason)
                        <div>
                            <label class="block text-sm font-medium text-gray-400 mb-1">Revocation Reason</label>
                            <div class="bg-slate-600 p-3 rounded text-yellow-100">
                                {{ $sanction->revocation_reason }}
                            </div>
                        </div>
                    @endif
                </div>
            </div>

            <!-- Rule Information -->
            @if($sanction->rule_id)
                @php
                    $ruleDetails = $sanction->getRuleDetails();
                @endphp
                @if($ruleDetails)
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
                            Rule Violation
                        </h3>
                        <div class="space-y-3">
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">Rule</label>
                                <div class="text-white font-medium">{{ $ruleDetails['rule']['title'] }}</div>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">Description</label>
                                <div class="text-gray-300">{{ $ruleDetails['rule']['description'] }}</div>
                            </div>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-400 mb-1">Escalation Level</label>
                                    <div class="text-white">Level {{ $sanction->escalation_level + 1 }}</div>
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-gray-400 mb-1">Rule Category</label>
                                    <div class="text-white">{{ $ruleDetails['rule']['category'] ?? 'General' }}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                @endif
            @endif

            <!-- Related Chat Log -->
            @if($sanction->chatLog)
                <div class="mb-6 p-4 bg-slate-700 rounded-lg">
                    <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M18 13V5a2 2 0 00-2-2H4a2 2 0 00-2 2v8a2 2 0 002 2h3l3 3 3-3h3a2 2 0 002-2zM5 7a1 1 0 011-1h8a1 1 0 110 2H6a1 1 0 01-1-1zm1 3a1 1 0 100 2h3a1 1 0 100-2H6z" clip-rule="evenodd"></path>
                        </svg>
                        Related Chat Log
                    </h3>
                    <div class="space-y-3">
                        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">Chat Type</label>
                                <div class="text-white">
                                    @if($sanction->chatLog->isVoiceChat())
                                        Voice Chat
                                    @else
                                        {{ strtoupper($sanction->chatLog->chat_type) }}
                                    @endif
                                </div>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">Received</label>
                                <div class="text-white">{{ $sanction->chatLog->created_at->format('M j, Y \a\t g:i A') }}</div>
                            </div>
                        </div>
                        @if($sanction->chatLog->message)
                            <div>
                                <label class="block text-sm font-medium text-gray-400 mb-1">Message</label>
                                <div class="bg-slate-600 p-3 rounded text-white">
                                    {{ $sanction->chatLog->message }}
                                </div>
                            </div>
                        @endif
                    </div>

                    <!-- Flag Information -->
                    @if($sanction->chatLog->flagged_reason)
                        <div class="mt-4">
                            <label class="block text-sm font-medium text-gray-400 mb-1">Flagged Reason</label>
                            <div class="bg-red-600 p-3 rounded text-white">
                                {{ $sanction->chatLog->flagged_reason }}
                            </div>
                        </div>
                    @endif
                </div>
            @endif

            <!-- Player's Sanction History -->
            @if($relatedSanctions->count() > 1)
                <div class="mb-6 p-4 bg-slate-700 rounded-lg">
                    <h3 class="text-lg font-semibold mb-4 flex items-center gap-2">
                        <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                            <path fill-rule="evenodd" d="M3 3a1 1 0 000 2v8a2 2 0 002 2h2.586l-1.293 1.293a1 1 0 101.414 1.414L10 15.414l2.293 2.293a1 1 0 001.414-1.414L12.414 15H15a2 2 0 002-2V5a1 1 0 100-2H3zm11.707 4.707a1 1 0 00-1.414-1.414L10 9.586 8.707 8.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path>
                        </svg>
                        All Sanctions for this Player ({{ $relatedSanctions->count() }})
                    </h3>
                    <div class="space-y-2 max-h-60 overflow-y-auto">
                        @foreach($relatedSanctions as $relatedSanction)
                            <div class="bg-slate-600 p-3 rounded flex justify-between items-start
                                @if($relatedSanction->id === $sanction->id) ring-2 ring-blue-500 @endif">
                                <div class="flex-1">
                                    <div class="flex items-center gap-2 mb-1">
                                        <span class="px-2 py-1 rounded text-xs font-medium
                                            @if($relatedSanction->type === 'mute') bg-yellow-600
                                            @elseif($relatedSanction->type === 'kick') bg-orange-600
                                            @elseif($relatedSanction->type === 'ban') bg-red-600
                                            @endif">
                                            {{ strtoupper($relatedSanction->type) }}
                                        </span>
                                        @if($relatedSanction->id === $sanction->id)
                                            <span class="px-2 py-1 rounded text-xs font-medium bg-blue-600">
                                                CURRENT
                                            </span>
                                        @endif
                                        <span class="px-2 py-1 rounded text-xs font-medium
                                            @if($relatedSanction->isActive()) bg-red-600
                                            @else bg-gray-600
                                            @endif">
                                            @if($relatedSanction->isActive()) ACTIVE
                                            @else EXPIRED
                                            @endif
                                        </span>
                                    </div>
                                    <div class="text-sm">{{ Str::limit($relatedSanction->reason, 100) }}</div>
                                    @if($relatedSanction->expires_at)
                                        <div class="text-xs text-gray-400 mt-1">
                                            @if($relatedSanction->isActive())
                                                Expires: {{ $relatedSanction->expires_at->diffForHumans() }}
                                            @else
                                                Expired: {{ $relatedSanction->expires_at->diffForHumans() }}
                                            @endif
                                        </div>
                                    @endif
                                </div>
                                <div class="text-xs text-right">
                                    <div>{{ $relatedSanction->created_at->format('M j, Y') }}</div>
                                    @if($relatedSanction->id !== $sanction->id)
                                        <a href="{{ route('sanctions.show', $relatedSanction) }}"
                                            class="text-blue-400 hover:text-blue-300 underline">
                                            View
                                        </a>
                                    @endif
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            @endif
    </div>
</x-layouts.app>
