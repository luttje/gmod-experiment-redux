<x-layouts.app>
    <x-slot name="title">
        Leaderboards
    </x-slot>

    @include('leaderboards.partials.epochs')

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4 font-bold">
        <p>
            There is no data to display. The leaderboards are updated every day, so please check back later.
        </p>
    </section>
</x-layouts.app>
