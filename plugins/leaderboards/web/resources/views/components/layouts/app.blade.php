<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}"
    class="{{ $isInGame ? 'bg-transparent' : 'bg-slate-800' }} font-sans h-full">

<head>
    <meta charset="utf-8">
    <meta name="viewport"
          content="width=device-width, initial-scale=1.0">

    <title>@isset($title){{ $title }}&nbsp;&bull;&nbsp;@endif{{ config('app.name') }}</title>

    @vite('resources/css/app.css')
</head>

<body class="flex flex-col h-full text-white">
    @if($isInGame)
    @if(!request()->routeIs('leaderboards.index'))
        <div class="container mx-auto pt-4 pb-0 px-8">
            <a href="{{ route('leaderboards.index') }}" class="inline-flex flex-row items-center gap-2 rounded transition duration-200 py-2 px-4 bg-slate-800 hover:bg-slate-900 }}">
                &larr; Back to Leaderboards Index
            </a>
        </div>
    @endif
    @else
    <header class="bg-slate-900">
        <div class="container mx-auto py-6 px-8">
            <div class="flex justify-between items-center">
                <a href="{{ route('leaderboards.index') }}">
                    <img src="/images/logo.png" alt="Logo" class="h-24 w-auto">
                </a>
                <div class="flex flex-col gap-2 text-right">
                    @isset($title)
                        <h2 class="text-2xl font-bold">
                            {{ $title }}
                        </h2>
                    @endif
                    @isset($subtitle)
                        <p>
                            {{ $subtitle }}
                        </p>
                    @endif
                </div>
            </div>
        </div>
    </header>
    @include('components.user')
    @endif

    <main class="container mx-auto py-6 px-8 flex-1">
        {{ $slot }}

        @isset($lastUpdatedAt)
        <div class="text-center italic">
            <div class="container mx-auto p-4 px-8 text-xs flex flex-col gap-1">
                <p>These leaderboards were last updated <strong>{{ $lastUpdatedAt->diffForHumans() }}</strong>.</p>
                <p>They are updated every night at midnight UTC.</p>
            </div>
        </div>
        @endisset
    </main>

    @include('sweetalert::alert')

    @unless($isInGame)
    <footer class="bg-slate-900 text-center">
        <div class="container mx-auto p-6 px-8 text-xs flex flex-col gap-1">
            <p>
                &copy; {{ date('Y') }} Experiment Redux
            </p>
            <p class="italic">
                Experiment Redux is open-source software released under the MIT license.
                Found a bug? <x-link href="https://experiment.games/issues" target="_blank">Thanks for reporting it!</x-link>
            </p>
        </div>
    </footer>
    @endunless
</body>

</html>
