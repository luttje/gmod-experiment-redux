<x-layouts.app>
    <x-slot name="title">
        Claim Rewards
    </x-slot>
    <x-slot name="subtitle">
        {{ $character['name'] }} in {{ $character['epoch']['name'] }}
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 text-center relative">
        <div class="absolute inset-0">
            <img src="{{ asset('images/medals/desk1.png') }}" alt="Character Background" class="w-full h-full object-cover opacity-25">
        </div>
        <div class="inline-flex flex-col max-w-sm relative">
            <p>
                These are the rewards you have earned with your character in '{{ $character['epoch']['name'] }}'.
            </p>
        </div>

        <div class="flex flex-row my-4 py-4 gap-4 overflow-x-auto relative">
            @forelse ($rewards as $reward)
                <div class="flex flex-col items-center justify-between gap-4 p-4 bg-slate-800/80">
                    <div class="h-60 w-60">
                        {!! $reward->render() !!}
                    </div>
                    <span class="font-bold">
                        {{ $reward->getName() }}
                    </span>
                </div>
            @empty
                <p class="text-xl font-bold">You have no rewards to claim.</p>
            @endforelse
        </div>

        <div class="inline-flex flex-col max-w-sm w-full relative">
            @if (count($rewards) > 0)
                <form action="{{ route('characters.claim-rewards', $character) }}" method="POST">
                    @csrf
                    <button type="submit" class="flex items-center justify-center gap-2 text-center bg-amber-400 hover:bg-amber-300 text-black p-4 rounded font-bold w-full">
                        <x-bi-gift-fill class="inline" /> Claim Rewards
                    </button>
                </form>
            @endif
        </div>
    </section>
</x-layouts.app>
