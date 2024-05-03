<div>
    <x-slot name="title">
        Sanctions
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
        <h2 class="text-2xl font-bold">
            Sanctions
        </h2>

        <x-table>
            <x-slot name="head">
                <x-table.heading>
                    Character Name
                </x-table.heading>
                <x-table.heading>
                    Type
                </x-table.heading>
                <x-table.heading>
                    Reason
                </x-table.heading>
                <x-table.heading>
                    Expires At
                </x-table.heading>
                <x-table.heading>
                    Issued At
                </x-table.heading>
                <x-table.heading>
                    Issued By
                </x-table.heading>
                <x-table.heading>
                    Actions
                </x-table.heading>
            </x-slot>

            <x-slot name="body">
                @foreach ($sanctions as $sanction)
                <x-table.row :even="$loop->even"
                             wire:key="sanction-{{ $sanction->id }}">
                    <x-table.cell>
                        {{ $sanction->character_name }}
                    </x-table.cell>
                    <x-table.cell>
                        {{ $sanction->type }}
                    </x-table.cell>
                    <x-table.cell>
                        {{ $sanction->reason }}
                    </x-table.cell>
                    <x-table.cell>
                        {{ $sanction->expires_at->diffForHumans() }}
                    </x-table.cell>
                    <x-table.cell>
                        {{ $sanction->created_at->diffForHumans() }}
                    </x-table.cell>
                    <x-table.cell>
                        {{ $sanction->issuer->name }}
                    </x-table.cell>
                    <x-table.cell class="flex gap-2 justify-end">
                        @if ($sanction->expires_at->isFuture())
                        <form method="POST"
                              wire:submit="revoke('{{ $sanction->id }}')">
                            @csrf
                            @method('PATCH')

                            <x-danger-button type="submit">
                                Revoke
                            </x-danger-button>
                        </form>
                        @endif
                    </x-table.cell>
                </x-table.row>
                @endforeach
            </x-slot>
        </x-table>

        <div>
            {{ $sanctions->links() }}
        </div>
    </section>
</div>
