<x-layouts.app>
    <header>
        <div class="flex justify-between items-center mb-6">
            <h2 class="font-semibold text-xl leading-tight">
                {{ __('Player Database') }}
            </h2>
            <div class="flex gap-2">
                <button onclick="exportPlayers()"
                        class="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700 text-sm font-medium">
                    Export All
                </button>
                <button onclick="refreshData()"
                        class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 text-sm font-medium">
                    Refresh
                </button>
            </div>
        </div>
    </header>

    <div class="bg-slate-800 overflow-hidden shadow-sm sm:rounded-lg">
        <!-- Statistics Banner -->
        <div class="mb-6 p-4 bg-slate-700 rounded-lg">
            <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4 text-center">
                <div>
                    <div class="text-2xl font-bold text-white" id="total-players">{{ $players->count() }}</div>
                    <div class="text-sm text-gray-400">Total Players</div>
                </div>
                <div>
                    <div class="text-2xl font-bold text-green-400" id="active-players">
                        {{ $players->where('created_at', '>=', now()->subDays(7))->count() }}
                    </div>
                    <div class="text-sm text-gray-400">Active (7d)</div>
                </div>
                <div>
                    <div class="text-2xl font-bold text-blue-400" id="with-characters">
                        {{ $players->whereNotNull('character_name')->count() }}
                    </div>
                    <div class="text-sm text-gray-400">With Characters</div>
                </div>
                <div>
                    <div class="text-2xl font-bold text-purple-400" id="anonymized-players">
                        {{ $players->whereNotNull('anonymized_at')->count() }}
                    </div>
                    <div class="text-sm text-gray-400">Anonymized</div>
                </div>
                <div>
                    <div class="text-2xl font-bold text-yellow-400" id="admin-players">
                        {{ $players->whereIn('rank', ['admin', 'superadmin'])->count() }}
                    </div>
                    <div class="text-sm text-gray-400">Staff Members</div>
                </div>
                <div>
                    <div class="text-2xl font-bold text-orange-400" id="unique-ips">
                        {{ $players->groupBy('ip_address')->count() }}
                    </div>
                    <div class="text-sm text-gray-400">Unique IPs</div>
                </div>
            </div>
        </div>

        <!-- Search and Filter Controls -->
        <div class="mb-6 p-4 bg-slate-700 rounded-lg">
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <div>
                    <label class="block text-sm font-medium text-gray-400 mb-1">Search Players</label>
                    <input type="text"
                           id="search-input"
                           placeholder="Steam name, character name, or Steam ID..."
                           class="w-full px-3 py-2 bg-slate-600 border border-slate-500 text-white rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm">
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-400 mb-1">Rank Filter</label>
                    <select id="rank-filter"
                            class="w-full px-3 py-2 bg-slate-600 border border-slate-500 text-white rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm">
                        <option value="">All Ranks</option>
                        <option value="player">Player</option>
                        <option value="admin">Admin</option>
                        <option value="superadmin">Super Admin</option>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-400 mb-1">Status Filter</label>
                    <select id="status-filter"
                            class="w-full px-3 py-2 bg-slate-600 border border-slate-500 text-white rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm">
                        <option value="">All Players</option>
                        <option value="with-character">With Character</option>
                        <option value="without-character">Without Character</option>
                        <option value="anonymized">Anonymized</option>
                        <option value="recent">Recent (7 days)</option>
                    </select>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-400 mb-1">Sort By</label>
                    <select id="sort-filter"
                            class="w-full px-3 py-2 bg-slate-600 border border-slate-500 text-white rounded focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-sm">
                        <option value="created_at_desc">Newest First</option>
                        <option value="created_at_asc">Oldest First</option>
                        <option value="steam_name_asc">Steam Name A-Z</option>
                        <option value="steam_name_desc">Steam Name Z-A</option>
                        <option value="character_name_asc">Character Name A-Z</option>
                        <option value="rank_asc">Rank</option>
                    </select>
                </div>
            </div>
            <div class="flex justify-between items-center mt-4">
                <button onclick="clearFilters()"
                        class="px-3 py-1 bg-slate-600 text-white rounded hover:bg-slate-500 text-sm">
                    Clear Filters
                </button>
                <div class="text-sm text-gray-400">
                    Showing <span id="showing-count">{{ $players->count() }}</span> of <span id="total-count">{{ $players->count() }}</span> players
                </div>
            </div>
        </div>

        <!-- Players Table -->
        <div class="overflow-x-auto">
            <table class="w-full text-sm">
                <thead class="bg-slate-700 text-gray-300 uppercase text-xs">
                    <tr>
                        <th class="px-4 py-3 text-left">Player Info</th>
                        <th class="px-4 py-3 text-left">Character</th>
                        <th class="px-4 py-3 text-left">Rank</th>
                        <th class="px-4 py-3 text-left">Status</th>
                        <th class="px-4 py-3 text-left">First Seen</th>
                        <th class="px-4 py-3 text-left">Actions</th>
                    </tr>
                </thead>
                <tbody id="players-table-body" class="bg-slate-800 divide-y divide-slate-700">
                    @foreach($players->sortByDesc('created_at') as $player)
                        <tr class="hover:bg-slate-700 transition-colors player-row"
                            data-steam-name="{{ strtolower($player->steam_name) }}"
                            data-character-name="{{ strtolower($player->character_name ?? '') }}"
                            data-steam-id="{{ $player->steam_id }}"
                            data-rank="{{ $player->rank }}"
                            data-created-at="{{ $player->created_at->timestamp }}"
                            data-has-character="{{ $player->character_name ? 'true' : 'false' }}"
                            data-anonymized="{{ $player->anonymized_at ? 'true' : 'false' }}"
                            data-is-recent="{{ $player->created_at->isAfter(now()->subDays(7)) ? 'true' : 'false' }}">

                            <!-- Player Info -->
                            <td class="px-4 py-3">
                                <div class="flex items-center gap-3">
                                    <div class="flex-shrink-0">
                                        <div class="w-10 h-10 bg-slate-600 rounded-full flex items-center justify-center">
                                            <svg class="w-5 h-5 text-gray-400" fill="currentColor" viewBox="0 0 20 20">
                                                <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"></path>
                                            </svg>
                                        </div>
                                    </div>
                                    <div class="min-w-0 flex-1">
                                        <div class="text-white font-medium truncate">{{ $player->steam_name }}</div>
                                        <div class="text-gray-400 text-xs font-mono truncate">{{ $player->steam_id }}</div>
                                    </div>
                                </div>
                            </td>

                            <!-- Character -->
                            <td class="px-4 py-3">
                                @if($player->character_name)
                                    <div class="text-white">{{ $player->character_name }}</div>
                                    @if($player->character_id)
                                        <div class="text-gray-400 text-xs">ID: {{ $player->character_id }}</div>
                                    @endif
                                @else
                                    <div class="text-gray-500 italic">No character</div>
                                @endif
                            </td>

                            <!-- Rank -->
                            <td class="px-4 py-3">
                                <span class="px-2 py-1 rounded text-xs font-medium
                                    @if($player->rank === 'superadmin') bg-red-600 text-red-100
                                    @elseif($player->rank === 'admin') bg-orange-600 text-orange-100
                                    @else bg-gray-600 text-gray-100
                                    @endif">
                                    {{ strtoupper($player->rank) }}
                                </span>
                            </td>

                            <!-- Status -->
                            <td class="px-4 py-3">
                                <div class="flex flex-col gap-1">
                                    @if($player->anonymized_at)
                                        <span class="px-2 py-1 rounded text-xs font-medium bg-purple-600 text-purple-100 w-fit">
                                            ANONYMIZED
                                        </span>
                                        <div class="text-xs text-gray-400">{{ $player->anonymized_at->format('M j, Y') }}</div>
                                    @endif

                                    @if($player->created_at->isAfter(now()->subDays(7)))
                                        <span class="px-2 py-1 rounded text-xs font-medium bg-green-600 text-green-100 w-fit">
                                            RECENT
                                        </span>
                                    @endif

                                    @if(!$player->character_name)
                                        <span class="px-2 py-1 rounded text-xs font-medium bg-yellow-600 text-yellow-100 w-fit">
                                            NO CHARACTER
                                        </span>
                                    @endif
                                </div>
                            </td>

                            <!-- First Seen -->
                            <td class="px-4 py-3">
                                <div class="text-white">{{ $player->created_at->format('M j, Y') }}</div>
                                <div class="text-gray-400 text-xs">{{ $player->created_at->format('g:i A') }}</div>
                                <div class="text-gray-500 text-xs">{{ $player->created_at->diffForHumans() }}</div>
                            </td>

                            <!-- Actions -->
                            <td class="px-4 py-3">
                                <div class="flex gap-2">
                                    <a href="{{ route('players.show', $player->steam_id) }}"
                                       class="px-3 py-1 bg-blue-600 text-white rounded hover:bg-blue-700 text-xs font-medium">
                                        View Profile
                                    </a>
                                    <button onclick="copyToClipboard('{{ $player->steam_id }}')"
                                            class="px-3 py-1 bg-gray-600 text-white rounded hover:bg-gray-700 text-xs font-medium"
                                            title="Copy Steam ID">
                                        Copy ID
                                    </button>
                                </div>
                            </td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <!-- Empty State -->
        <div id="no-results" class="hidden p-8 text-center">
            <svg class="w-16 h-16 mx-auto text-gray-400 mb-4" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M8 4a4 4 0 100 8 4 4 0 000-8zM2 8a6 6 0 1110.89 3.476l4.817 4.817a1 1 0 01-1.414 1.414l-4.816-4.816A6 6 0 012 8z" clip-rule="evenodd"></path>
            </svg>
            <h3 class="text-lg font-medium text-white mb-2">No Players Found</h3>
            <p class="text-gray-400">No players match your current search criteria.</p>
        </div>
    </div>

    <!-- JavaScript for filtering and interactions -->
    <script>
        let allPlayers = [];
        let filteredPlayers = [];

        // Initialize the page
        document.addEventListener('DOMContentLoaded', function() {
            initializeFilters();
            cachePlayerData();
        });

        function cachePlayerData() {
            const rows = document.querySelectorAll('.player-row');
            allPlayers = Array.from(rows).map(row => ({
                element: row,
                steamName: row.dataset.steamName,
                characterName: row.dataset.characterName,
                steamId: row.dataset.steamId,
                rank: row.dataset.rank,
                createdAt: parseInt(row.dataset.createdAt),
                hasCharacter: row.dataset.hasCharacter === 'true',
                anonymized: row.dataset.anonymized === 'true',
                isRecent: row.dataset.isRecent === 'true'
            }));
            filteredPlayers = [...allPlayers];
        }

        function initializeFilters() {
            const searchInput = document.getElementById('search-input');
            const rankFilter = document.getElementById('rank-filter');
            const statusFilter = document.getElementById('status-filter');
            const sortFilter = document.getElementById('sort-filter');

            searchInput.addEventListener('input', debounce(applyFilters, 300));
            rankFilter.addEventListener('change', applyFilters);
            statusFilter.addEventListener('change', applyFilters);
            sortFilter.addEventListener('change', applyFilters);
        }

        function applyFilters() {
            const searchTerm = document.getElementById('search-input').value.toLowerCase();
            const rankFilter = document.getElementById('rank-filter').value;
            const statusFilter = document.getElementById('status-filter').value;
            const sortFilter = document.getElementById('sort-filter').value;

            // Filter players
            filteredPlayers = allPlayers.filter(player => {
                // Search filter
                const matchesSearch = !searchTerm ||
                    player.steamName.includes(searchTerm) ||
                    player.characterName.includes(searchTerm) ||
                    player.steamId.includes(searchTerm);

                // Rank filter
                const matchesRank = !rankFilter || player.rank === rankFilter;

                // Status filter
                let matchesStatus = true;
                switch(statusFilter) {
                    case 'with-character':
                        matchesStatus = player.hasCharacter;
                        break;
                    case 'without-character':
                        matchesStatus = !player.hasCharacter;
                        break;
                    case 'anonymized':
                        matchesStatus = player.anonymized;
                        break;
                    case 'recent':
                        matchesStatus = player.isRecent;
                        break;
                }

                return matchesSearch && matchesRank && matchesStatus;
            });

            // Sort players
            filteredPlayers.sort((a, b) => {
                switch(sortFilter) {
                    case 'created_at_asc':
                        return a.createdAt - b.createdAt;
                    case 'created_at_desc':
                        return b.createdAt - a.createdAt;
                    case 'steam_name_asc':
                        return a.steamName.localeCompare(b.steamName);
                    case 'steam_name_desc':
                        return b.steamName.localeCompare(a.steamName);
                    case 'character_name_asc':
                        return a.characterName.localeCompare(b.characterName);
                    case 'rank_asc':
                        const rankOrder = { 'superadmin': 0, 'admin': 1, 'player': 2 };
                        return (rankOrder[a.rank] || 3) - (rankOrder[b.rank] || 3);
                    default:
                        return b.createdAt - a.createdAt;
                }
            });

            updateTable();
            updateCounts();
        }

        function updateTable() {
            const tbody = document.getElementById('players-table-body');
            const noResults = document.getElementById('no-results');

            // Hide all rows first
            allPlayers.forEach(player => {
                player.element.style.display = 'none';
            });

            if (filteredPlayers.length === 0) {
                tbody.style.display = 'none';
                noResults.classList.remove('hidden');
            } else {
                tbody.style.display = '';
                noResults.classList.add('hidden');

                // Show filtered rows in order
                filteredPlayers.forEach((player, index) => {
                    player.element.style.display = '';
                    tbody.appendChild(player.element);
                });
            }
        }

        function updateCounts() {
            document.getElementById('showing-count').textContent = filteredPlayers.length;
        }

        function clearFilters() {
            document.getElementById('search-input').value = '';
            document.getElementById('rank-filter').value = '';
            document.getElementById('status-filter').value = '';
            document.getElementById('sort-filter').value = 'created_at_desc';
            applyFilters();
        }

        function copyToClipboard(text) {
            navigator.clipboard.writeText(text).then(() => {
                showToast('Steam ID copied to clipboard!');
            });
        }

        function exportPlayers() {
            const data = filteredPlayers.map(player => ({
                steam_name: player.element.querySelector('td:first-child .text-white').textContent,
                steam_id: player.steamId,
                character_name: player.hasCharacter ? player.element.querySelector('td:nth-child(2) .text-white')?.textContent : null,
                rank: player.rank,
                created_at: new Date(player.createdAt * 1000).toISOString()
            }));

            const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = `players_export_${new Date().toISOString().split('T')[0]}.json`;
            a.click();
            URL.revokeObjectURL(url);

            showToast('Player data exported successfully!');
        }

        function refreshData() {
            window.location.reload();
        }

        function showToast(message) {
            // Simple toast notification
            const toast = document.createElement('div');
            toast.className = 'fixed top-4 right-4 bg-green-600 text-white px-4 py-2 rounded shadow-lg z-50';
            toast.textContent = message;
            document.body.appendChild(toast);

            setTimeout(() => {
                toast.remove();
            }, 3000);
        }

        function debounce(func, wait) {
            let timeout;
            return function executedFunction(...args) {
                const later = () => {
                    clearTimeout(timeout);
                    func(...args);
                };
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
            };
        }
    </script>
</x-layouts.app>
