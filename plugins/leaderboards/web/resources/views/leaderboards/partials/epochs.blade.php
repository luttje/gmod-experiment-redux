<section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4 font-bold">
    <div class="flex flex-row flex-wrap items-center gap-4">
        <h3>
            Epochs:
        </h3>
        @php
            $route = Route::currentRouteName();

            if (strpos($route, 'historic') === false) {
                $route .= '-historic';
            }

            $metricId = null;

            // Get the metric ID from the route
            if (strpos($route, 'show') !== false) {
                $metricId = Route::current()->parameter('metric');
            }
        @endphp
        @foreach ($epochs as $epoch)
            <a href="{{ route($route, [ 'epoch' => $epoch['id'], 'metric' => $metricId ]) }}" class="flex flex-row items-center gap-2 rounded transition duration-200 py-2 px-4 {{ $epoch['id'] == $selectedEpoch->id ? 'bg-amber-400 hover:bg-amber-500 text-black' : 'bg-slate-800 hover:bg-slate-900' }}">
                {{ $epoch['name'] }}
                @if ($epoch['id'] == $latestEpoch->id)
                    <span class="text-xs font-normal text-amber-800/75">
                        (latest)
                    </span>
                @endif
            </a>
        @endforeach
    </div>
</section>

<section class="text-xs text-slate-400 flex flex-col text-center mb-4">
    @if ($selectedEpoch->ends_at->isPast())
        <span>This epoch ran from <strong>{{ $selectedEpoch->started_at->format('Y-m-d H:i:s') }} (UTC)</strong> to <strong>{{ $selectedEpoch->ends_at->format('Y-m-d H:i:s') }} (UTC)</strong></span>
    @else
        <span>This epoch started on <strong>{{ $selectedEpoch->started_at->format('Y-m-d H:i:s') }} (UTC)</strong> and ends in</span>

        <span id="countdown"
            class="text-amber-400 font-bold text-xl"
        ></span>

        <script>
            const countdown = document.getElementById('countdown');
            const epochEndsAtUTC = new Date("{{ $selectedEpoch->ends_at->format('Y-m-d H:i:s') }} UTC").getTime();

            const updateCountdown = () => {
                const now = new Date().getTime();
                const distanceInSeconds = epochEndsAtUTC - now;

                if (distanceInSeconds < 0) {
                    countdown.innerHTML = '0s';
                    return;
                }

                const weeks = Math.floor(distanceInSeconds / (1000 * 60 * 60 * 24 * 7));
                const days = Math.floor((distanceInSeconds % (1000 * 60 * 60 * 24 * 7)) / (1000 * 60 * 60 * 24));
                const hours = Math.floor((distanceInSeconds % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((distanceInSeconds % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((distanceInSeconds % (1000 * 60)) / 1000);

                if (weeks > 0)
                    countdown.innerHTML = `${weeks}w ${days}d ${hours}h ${minutes}m ${seconds}s`;
                else if (days > 0)
                    countdown.innerHTML = `${days}d ${hours}h ${minutes}m ${seconds}s`;
                else if (hours > 0)
                    countdown.innerHTML = `${hours}h ${minutes}m ${seconds}s`;
                else if (minutes > 0)
                    countdown.innerHTML = `${minutes}m ${seconds}s`;
                else if (seconds > 0)
                    countdown.innerHTML = `${seconds}s`;
                else if (distanceInSeconds > 0)
                    countdown.innerHTML = `1s`;
            };

            updateCountdown();
            setInterval(updateCountdown, 1000);
        </script>
    @endif
</section>
