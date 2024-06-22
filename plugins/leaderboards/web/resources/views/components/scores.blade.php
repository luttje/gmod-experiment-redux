@include('components.epochs')

<section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-2 font-bold">
    <div class="flex flex-row gap-4 items-center rounded bg-slate-900 p-4 text-slate-400">
        <span class="flex w-10 shrink-0 text-xl">
            #
        </span>
        <span class="text-xl md:w-96">
            Character
        </span>
        <span class="text-xl flex-1 text-slate-600">
            Player
        </span>
        <span class="text-xl">
            Value
        </span>
    </div>
    <ol class="flex flex-col gap-2">
        @forelse ($characterScores as $characterScore)
        <li>
            @php
            $character = $characterScore['character'];
            $player = $character['player'];
            $score = $characterScore['sum'];
            $rowColorClasses = 'bg-slate-800 p-4 hover:bg-slate-900 text-slate-400';

            if ($loop->iteration === 1) {
                $rowColorClasses = 'bg-amber-400 p-4 hover:bg-amber-300 text-slate-900';
            } elseif ($loop->iteration === 2) {
                $rowColorClasses = 'bg-amber-700 p-4 hover:bg-amber-600 text-slate-900';
            } elseif ($loop->iteration === 3) {
                $rowColorClasses = 'bg-zinc-200 p-4 hover:bg-zinc-100 text-slate-900';
            }
            @endphp
            <div class="group flex flex-row gap-4 items-center rounded cursor-pointer {{ $rowColorClasses }} transition duration-200">
                <span class="flex w-10 shrink-0 text-xl">
                    {{ $loop->iteration }}
                </span>
                <span class="text-xl md:w-96">
                    {{ $character['name'] }}
                </span>
                <span class="flex flex-row gap-2 items-center text-xl flex-1 text-amber-900 group-hover:text-amber-800">
                    {{ $player['steam_name'] }}
                    @auth
                    @if (user() && user()->steam_id === $player['steam_id'])
                    <span class="text-white ml-4"><x-bi-steam class="inline w-4 h-4" /></span>
                    @endif
                    @endauth
                </span>
                <span class="text-xl">
                    {{ $score }}
                </span>
            </div>
        </li>
        @empty
        <li>
            <div class="flex flex-row gap-4 items-center rounded bg-slate-800 p-4 text-slate-400">
                <span class="flex w-10 shrink-0 text-xl">
                </span>
                <span class="text-xl">
                    No characters have scored in this leaderboard yet.
                </span>
                <span class="text-xl flex-1 text-slate-600">
                </span>
                <span class="text-xl">
                </span>
            </div>
        </li>
        @endforelse
    </ol>
</section>
