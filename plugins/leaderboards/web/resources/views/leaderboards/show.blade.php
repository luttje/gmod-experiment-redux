<x-layouts.app>
    <x-slot name="title">
        '{{ $metric->name }}' Leaderboard
    </x-slot>
    <x-slot name="subtitle">
        {{ $metric->description }}
    </x-slot>

    <x-scores :characterScores="$characterScores" />
</x-layouts.app>
