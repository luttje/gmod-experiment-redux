<section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-2 font-bold">
    <div class="flex flex-row gap-4 items-center rounded bg-slate-900 p-4 text-slate-400">
        <span class="flex w-10 shrink-0 text-xl">
            #
        </span>
        <span class="text-xl">
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
        @foreach ($characterScores as $characterScore)
        <li>
            @php
            $character = $characterScore['character'];
            $score = $characterScore['value'];
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
                <span class="text-xl">
                    {{ $character->name }}
                </span>
                <span class="text-xl flex-1 text-slate-600 group-hover:text-slate-400">
                    {{ $character->player->name }}
                </span>
                <span class="text-xl">
                    {{ $score }}
                </span>
            </div>
        </li>
        @endforeach
    </ol>
</section>
