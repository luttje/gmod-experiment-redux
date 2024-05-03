<table class="w-full bg-slate-900 rounded">
    @isset($head)
    <thead>
        <tr class="bg-slate-950">
            {{ $head }}
        </tr>
    </thead>
    @endisset
    <tbody>
        {{ $body }}
    </tbody>
</table>
