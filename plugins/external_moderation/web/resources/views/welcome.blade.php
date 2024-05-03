<x-layouts.guest>
    <x-slot name="title">
        External Moderation
    </x-slot>

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
