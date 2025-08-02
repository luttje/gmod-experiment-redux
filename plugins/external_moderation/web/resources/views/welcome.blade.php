<x-layouts.guest>
    <x-slot name="title">
        External Moderation
    </x-slot>

    @php
        $rules = require app_path('Data/Rules.php');
    @endphp

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
        <h2 class="text-2xl font-bold">
            Rules
        </h2>

        <p>
            The following rules apply to the external moderation system. Please ensure you understand them before proceeding.
        </p>

        <ul class="list-disc pl-6">
            @foreach ($rules as $rule)
                <li class="mb-2">
                    <h3 class="font-bold">{{ $rule['title'] }}</h3>
                    <p>{{ $rule['description'] }}</p>
                </li>
            @endforeach
        </ul>
    </section>

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
        <p>
            This tool is designed to externally moderate Experiment chat logs.
            If you're part of the moderation team, you can log in using the button below.
        </p>
        <div class="flex flex-row gap-2 justify-center">
            <x-navigation-button href="{{ route('login') }}">
                Log in
            </x-navigation-button>
        </div>
    </section>
</x-layouts.guest>
