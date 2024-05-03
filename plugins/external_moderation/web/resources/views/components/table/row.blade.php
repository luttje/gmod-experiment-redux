<tr {{
    $attributes->class([
        'bg-slate-800' => isset($even) && $even,
    ])
}}>
    {{ $slot }}
</tr>
