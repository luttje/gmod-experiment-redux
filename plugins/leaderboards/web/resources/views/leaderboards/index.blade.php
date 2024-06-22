<x-layouts.app>
    <x-slot name="title">
        Leaderboards
    </x-slot>

    @include('leaderboards.partials.epochs')

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4 font-bold">
        <p>
            Select a leaderboard to view the top players in that category.
        </p>
        @if ($overallLeader)
            <a href="{{ route('leaderboards.overall') }}" class="group flex flex-col overflow-clip rounded bg-slate-800 hover:bg-slate-900 transition duration-200">
                <h3 class="text-xl text-center font-bold p-4">
                    Overall Leader
                </h3>

                @php
                $leadingCharacter = $overallLeader;
                @endphp

                @if ($leadingCharacter)
                <p class="flex flex-row gap-4 p-4 bg-amber-400 flex-1 text-black group-hover:bg-amber-200 transition duration-200">
                    <span class="font-normal">Leader:</span>
                    <span class="flex-1 text-center">
                        <span class="font-bold">{{ $leadingCharacter['character']['name'] }}</span>
                        <span class="text-amber-600">({{ $leadingCharacter['player']['steam_name'] }})</span>
                    </span>
                    <span>{{ $leadingCharacter['value'] }}</span>
                </p>
                @endif
            </a>
        @endif

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            @foreach ($metrics as $metric)
                <a href="{{ route('leaderboards.show', $metric['id']) }}" class="group flex flex-col overflow-clip rounded bg-slate-800 hover:bg-slate-900 transition duration-200">
                    <h3 class="text-xl text-center font-bold p-4">
                        {{ $metric['name'] }}
                    </h3>

                    @php
                    $leadingCharacter = $metric['leader'];
                    @endphp

                    @if ($leadingCharacter)
                    <p class="flex flex-row gap-4 p-4 bg-amber-400 flex-1 text-black group-hover:bg-amber-200 transition duration-200">
                        <span class="font-normal">Leader:</span>
                        <span class="flex-1 text-center">
                            <span class="font-bold">{{ $leadingCharacter['character']['name'] }}</span>
                            <span class="text-amber-600">({{ $leadingCharacter['player']['steam_name'] }})</span>
                        </span>
                        <span>{{ $leadingCharacter['sum'] }}</span>
                    </p>
                    @else
                    <p class="flex flex-row gap-4 p-4 bg-slate-800 flex-1 text-slate-400 font-normal text-xs justify-center items-center">
                        No characters have scored in this leaderboard yet.
                    </p>
                    @endif
                </a>
            @endforeach
        </div>
    </section>
</x-layouts.app>
