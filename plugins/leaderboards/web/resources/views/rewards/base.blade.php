<div class="relative h-full overflow-clip hover:scale-[200%] hover:drop-shadow-xl transition-transform duration-500 ease-[cubic-bezier(1,-0.03,.28,1.5)]">
    @php
    $randomAnimationDelay = rand(2000, 10000);
    @endphp
    @foreach($medalImageStack as $medalImageOrKey => $medalImageOrEffect)
        @php
        $medalImage = is_string($medalImageOrKey) ? $medalImageOrKey : $medalImageOrEffect;
        $shouldShine = is_string($medalImageOrKey) ? ($medalImageOrEffect === 'shine') : false;
        @endphp
        <img src="{{ asset('images/medals/' . $medalImage) }}" alt="Medal" class="absolute w-full h-full object-contain object-center">
        @if ($shouldShine)
            <div class="absolute w-full h-full shine" style="-webkit-mask-image: url({{ asset('images/medals/' . $medalImage) }}); mask-image: url({{ asset('images/medals/' . $medalImage) }});">
                <div style="animation-delay: {{ $randomAnimationDelay }}ms;"></div>
            </div>
        @endif
    @endforeach
</div>
