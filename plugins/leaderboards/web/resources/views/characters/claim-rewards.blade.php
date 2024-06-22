<x-layouts.app>
    <x-slot name="title">
        Claim Rewards
    </x-slot>
    <x-slot name="subtitle">
        {{ $character['name'] }} in {{ $character['epoch']['name'] }}
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 text-center">
        <div class="inline-flex flex-col gap-4 max-w-sm">
            <p>
                These are the rewards you have earned with your character in '{{ $character['epoch']['name'] }}'.
            </p>

            <div class="grid grid-cols-1 gap-4">
                @forelse ($rewards as $reward)
                    <div class="flex flex-row items-center justify-between gap-4 p-4 bg-slate-800 transition duration-200">
                        <span class="font-bold">
                            {{ $reward }}
                        </span>
                        <span class="flex flex-row gap-2 items-center text-xl font-bold">
                            <span class="text-amber-400">
                                <x-bi-check2-circle />
                            </span>
                        </span>
                    </div>
                @empty
                    <p class="text-xl font-bold">You have no rewards to claim.</p>
                @endforelse
            </div>
            @if (count($rewards) > 0)
                <form action="{{ route('characters.claim-rewards', $character) }}" method="POST">
                    @csrf
                    <button type="submit" class="flex items-center justify-center gap-2 text-center bg-amber-400 hover:bg-amber-300 text-black p-4 rounded font-bold min-w-full">
                        <x-bi-gift-fill class="inline" /> Claim Rewards
                    </button>
                </form>
            @endif
        </div>
    </section>
</x-layouts.app>
