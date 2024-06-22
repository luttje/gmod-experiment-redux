<div class="relative h-full">
    @foreach($medalImageStack as $medalImage)
        <img src="{{ asset('images/medals/' . $medalImage) }}" alt="Medal" class="absolute w-full h-full object-contain object-center">
    @endforeach
</div>
