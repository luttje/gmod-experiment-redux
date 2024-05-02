<a {{
    $attributes->merge([
        'class' => 'text-brand-600 hover:text-brand-400',
        'href' => $href,
    ])
}}>
    {{ $slot }}
</a>
