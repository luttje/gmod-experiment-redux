<x-layouts.app>
    <x-slot name="title">
        Characters & Rewards
    </x-slot>

    @if (user()->steam_id && user()->discord_id)
        <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
            <p>
                These are the characters you have created during different epochs.
            </p>

            <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                @forelse ($characters as $character)
                    <div class="flex flex-col rounded bg-slate-800 transition duration-200 overflow-visible">
                        <span class="text-xs text-center p-4">{{ $character['epoch']['name'] }}</span>
                        <h3 class="text-xl text-center font-bold p-4 bg-amber-400 text-black">
                            {{ $character['name'] }}
                        </h3>

                        @foreach ($character->scores as $score)
                            <p class="flex flex-row items-center justify-between gap-4 p-4 flex-1 bg-slate-800 text-slate-400 transition duration-200">
                                <span>
                                    {{ $score['name'] }}
                                </span>
                                <span class="flex flex-row gap-2 items-center text-xl font-bold">
                                    @if ($score['isLeader'])
                                        <span class="text-amber-400">
                                            <x-bi-trophy-fill />
                                        </span>
                                    @endif
                                    {{ $score['sum'] }}
                                </span>
                            </p>
                        @endforeach

                        @if ($character->characterRewards->count() > 0)
                            <div class="flex flex-col gap-4 p-4">
                                <h4 class="text-xl font-bold text-center">Claimed Rewards</h4>
                                <div class="flex flex-row justify-center gap-4">
                                    @foreach ($character->characterRewards as $characterReward)
                                        <div class="group relative h-16 w-16">
                                            <div class="h-16 w-16">
                                                {!! $characterReward->reward->render() !!}
                                            </div>

                                            <div class="hidden group-hover:block absolute top-full left-full bg-slate-600 whitespace-nowrap text-xs text-white p-2 rounded z-50 drop-shadow-lg">
                                                {{ $characterReward->reward->getName() }}
                                            </div>
                                        </div>
                                    @endforeach
                                </div>
                            </div>
                        @else
                            <a href="{{ route('characters.claim-rewards', $character) }}" class="flex items-center gap-2 justify-center text-center bg-amber-400 hover:bg-amber-300 text-black p-4 rounded-b font-bold">
                                <x-bi-gift-fill class="inline" /> Claim Rewards
                            </a>
                        @endif
                    </div>
                @empty
                    <p class="text-xl font-bold">You have no characters yet.</p>
                @endforelse
            </div>

            {{ $characters->links('pagination::tailwind') }}
        </section>
    @else
        <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
            <span class="font-bold">
                You must
                <a href="{{ route('auth.steam') }}" class="text-amber-400 hover:text-amber-300">connect your Steam</a>
                and
                <a href="{{ route('auth.discord') }}" class="text-amber-400 hover:text-amber-300">Discord</a>
                accounts to view your characters and rewards.
            </span>
        </section>
    @endif
</x-layouts.app>
