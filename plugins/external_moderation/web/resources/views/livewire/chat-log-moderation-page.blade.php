<div>
    <x-slot name="title">
        Chat Logs
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
        <p>
            This is a list of all chat logs that have yet to be moderated.
        </p>
    </section>

    <section class="rounded bg-slate-700 p-4 flex flex-col gap-4">
        <h2 class="text-2xl font-bold">
            Chat Logs
        </h2>

        <x-table>
            <x-slot name="head">
                <x-table.heading>

                </x-table.heading>
                <x-table.heading>
                    Character Name
                </x-table.heading>
                <x-table.heading>
                    Message
                </x-table.heading>
                <x-table.heading>
                    Received
                </x-table.heading>
                <x-table.heading class="text-right">
                    Actions
                </x-table.heading>
            </x-slot>

            <x-slot name="body">
                @foreach ($chatLogs as $chatLog)
                <x-table.row :even="$loop->even"
                             wire:key="chat-log-{{ $chatLog->id }}">
                    <x-table.cell class="w-0 pr-0">
                        @if ($chatLog->isFlagged())
                        <span class="text-red-600 text-bold"
                            title="Flagged">❗</span>
                        @endif
                    </x-table.cell>
                    <x-table.cell>
                        {{ $chatLog->character_name }}
                    </x-table.cell>
                    <x-table.cell>
                        @if ($chatLog->isVoiceChat())
                        <span class="text-emerald-600 text-xs">(Voice Chat)</span>

                        @if (empty($chatLog->message))
                        <span class="text-gray-400 text-xs">Pending transcription...</span>
                        @else
                        {{ $chatLog->message }}
                        @endif
                        @else
                        {{ $chatLog->message }}
                        @endif
                    </x-table.cell>
                    <x-table.cell>
                        {{ $chatLog->created_at->diffForHumans() }}
                    </x-table.cell>
                    <x-table.cell class="flex gap-2 justify-end"
                                  x-data="{
                            sanctioning: false,
                        }">
                        <div x-show="sanctioning"
                             class="fixed inset-0 bg-slate-800 bg-opacity-75 flex items-center justify-center"
                             x-cloak>
                            <div @click.outside="sanctioning = false"
                                 class="bg-slate-900 p-4 rounded shadow-lg text-start">
                                <h3 class="text-xl font-bold mb-4">
                                    Sanction
                                </h3>
                                <form method="POST"
                                      wire:submit="moderate('{{ $chatLog->id }}','sanction')"
                                      class="flex flex-col gap-4">
                                    @csrf
                                    @method('PATCH')

                                    <div class="flex flex-col">
                                        <x-input-label for="type" :value="__('Reason')" />
                                        <select wire:model="type"
                                                class="bg-slate-800 text-white rounded p-2">
                                            <option value="" disabled selected>Select a sanction type</option>
                                            <option value="mute">Mute</option>
                                            <option value="kick">Kick</option>
                                            <option value="ban">Ban</option>
                                        </select>
                                        <x-input-error :messages="$errors->get('type')" class="mt-2" />
                                    </div>

                                    <div class="flex flex-col">
                                        <x-input-label for="reason" :value="__('Reason')" />
                                        <input type="text"
                                        wire:model="reason"
                                            placeholder="Reason"
                                            class="bg-slate-800 text-white rounded p-2">
                                        <x-input-error :messages="$errors->get('reason')" class="mt-2" />
                                    </div>

                                    <div class="flex flex-col">
                                        <x-input-label for="expires_at" :value="__('Expires at (UTC)')" />
                                        <input type="datetime-local"
                                        wire:model="expires_at"
                                               class="bg-slate-800 text-white rounded p-2"
                                               required>
                                        <span class="text-xs text-gray-400">Current UTC time: {{ now()->format('Y-m-d H:i') }}</span>
                                        <x-input-error :messages="$errors->get('expires_at')" class="mt-2" />
                                    </div>

                                    <x-danger-button type="submit">
                                        Sanction
                                    </x-danger-button>
                                </form>
                            </div>
                        </div>

                        <x-primary-button type="submit"
                                          @click="sanctioning = !sanctioning">
                            Sanction
                        </x-primary-button>

                        <form method="POST"
                              wire:submit="moderate('{{ $chatLog->id }}')">
                            @csrf
                            @method('PATCH')

                            <x-primary-button type="submit">
                                Mark Safe
                            </x-primary-button>
                        </form>
                    </x-table.cell>
                </x-table.row>
                @endforeach
            </x-slot>
        </x-table>

        <div>
            {{ $chatLogs->links() }}
        </div>
    </section>
</div>
