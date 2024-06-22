<section class="bg-slate-700">
    <div class="container mx-auto p-4 px-8 flex flex-col md:flex-row md:items-center justify-between gap-2">
        <div class="flex flex-col gap-2 mb-2 md:mb-0">
            @auth
                <span class="font-bold text-xl">
                    Welcome back, {{ user()->discord_name ?? user()->steam_nickname }}!
                </span>
            @endauth
            <span class="text-xs italic">
                By connecting your Discord and Steam accounts, you can claim your characters and rewards.
            </span>
        </div>
        <div class="flex flex-row justify-between items-center gap-4">
            @if (user() && user()->discord_id)
                <div class="flex flex-row items-center gap-2 font-bold">
                    <x-bi-discord class="w-4 h-4" />
                    {{ user()->discord_name }}
                </div>
            @else
                <a href="{{ route('auth.discord') }}" class="flex flex-col items-center gap-2 whitespace-nowrap rounded transition duration-200 py-2 px-4 bg-slate-800 hover:bg-slate-900 text-white">
                    <span class="text-xs">Sign in through / Connect</span>
                    <span class="flex flex-row items-center gap-2">
                        <x-bi-discord class="w-4 h-4" />
                        Discord
                    </span>
                </a>
            @endif

            @if (user() && user()->steam_id)
                <div class="flex flex-row items-center gap-2 font-bold">
                    <x-bi-steam class="w-4 h-4" />
                    {{ user()->steam_nickname }}
                </div>
            @else
                <a href="{{ route('auth.steam') }}" class="flex flex-col items-center gap-2 whitespace-nowrap rounded transition duration-200 py-2 px-4 bg-slate-800 hover:bg-slate-900 text-white">
                    <span class="text-xs">Sign in through / Connect</span>
                    <span class="flex flex-row items-center gap-2">
                        <x-bi-steam class="w-4 h-4" />
                        Steam
                    </span>
                </a>
            @endif
        </div>
    </div>
</section>
