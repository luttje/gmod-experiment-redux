<div>
    <x-slot name="title">
        Chat Logs
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
        <p>
            This is a list of all chat logs that have yet to be moderated.
        </p>
    </section>

    <section class="rounded bg-slate-700 p-4 flex flex-col gap-4"
             x-data="{
            volume: 1,
            isPlayingAudio: false,
            audioPlayer: null,
            playAudio: function (url) {
                if (this.isPlayingAudio) {
                    return;
                }

                this.isPlayingAudio = true;

                this.audioPlayer = new Audio(url);
                this.audioPlayer.volume = this.volume;
                this.audioPlayer.play();

                this.audioPlayer.addEventListener('ended', () => {
                    this.isPlayingAudio = false;
                });
            },
            stopAudio: function () {
                if (this.audioPlayer) {
                    this.audioPlayer.pause();
                    this.isPlayingAudio = false;
                }
            },
        }">
        <div class="fixed bottom-0 right-0 p-4 bg-slate-800 rounded shadow-lg">
            <div class="flex gap-4 items-center">
                <button @click="stopAudio()"
                        class="text-red-600">
                    <svg class="w-6 h-6"
                         fill="none"
                         stroke="currentColor"
                         viewBox="0 0 24 24"
                         xmlns="http://www.w3.org/2000/svg">
                        <path stroke-linecap="round"
                              stroke-linejoin="round"
                              stroke-width="2"
                              d="M6 18L18 6M6 6l12 12"></path>
                    </svg>
                </button>
                <input type="range"
                       min="0"
                       max="1"
                       step="0.01"
                       value="1"
                       x-model="volume"
                       class="w-32">
            </div>
        </div>
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
                    Type
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
                    <x-table.cell class="text-xs">
                        @if ($chatLog->isVoiceChat())
                        <a class="text-emerald-600"
                           @click="$wire.listen('{{ $chatLog->id }}').then((url) => { url ? playAudio(url) : void(0); })"
                           href="javascript:void(0)">(Voice)</a>
                        @else
                        ({{ strtoupper($chatLog->chat_type) }})
                        @endif
                    </x-table.cell>
                    <x-table.cell>
                        @if (empty($chatLog->message))
                        <span class="text-gray-400 text-xs">Pending transcription...</span>
                        @else
                        {{ $chatLog->message }}
                        @endif
                    </x-table.cell>
                    <x-table.cell>
                        {{ $chatLog->created_at->diffForHumans() }}
                    </x-table.cell>
                    @php
                    $rules = require app_path('Data/Rules.php');
                    @endphp
                    <x-table.cell class="flex gap-2 justify-end"
                                  x-data="{
                            sanctioning: false,
                            selectedOffense: '',
                            sanctionType: '',
                            reason: '',
                            expiresAt: '',
                            offenseRules: {{ json_encode($rules) }},
                            calculateExpiryTime(minutes) {
                                if (minutes === -1) return ''; // Permanent ban
                                if (minutes === 0) return ''; // Kick (no expiry needed)

                                const now = new Date();
                                const expiry = new Date(now.getTime() + (minutes * 60000));
                                return expiry.toISOString().slice(0, 16);
                            },
                            selectOffense() {
                                const [ruleID, escalationID] = this.selectedOffense.split('.');

                                if (this.selectedOffense && this.offenseRules[ruleID]) {
                                    const rule = this.offenseRules[ruleID];
                                    const escalation = rule.escalations[escalationID];

                                    this.sanctionType = escalation.type;
                                    this.reason = escalation.reason;
                                    this.expiresAt = this.calculateExpiryTime(escalation.duration_in_minutes);

                                    $wire.set('type', escalation.type);
                                    $wire.set('reason', escalation.reason);
                                    $wire.set('expires_at', this.expiresAt);
                                } else {
                                    this.sanctionType = '';
                                    this.reason = '';
                                    this.expiresAt = '';
                                    $wire.set('type', '');
                                    $wire.set('reason', '');
                                    $wire.set('expires_at', '');
                                }
                            }
                        }">
                        <div x-show="sanctioning"
                             class="fixed inset-0 bg-slate-800 bg-opacity-75 flex items-center justify-center z-50"
                             x-cloak>
                            <div @click.outside="sanctioning = false"
                                 class="bg-slate-900 p-6 rounded shadow-lg text-start max-w-md w-full max-h-[90vh] overflow-y-auto">
                                <h3 class="text-xl font-bold mb-4">
                                    Sanction Player
                                </h3>
                                <form method="POST"
                                      wire:submit="moderate('{{ $chatLog->id }}','sanction')"
                                      class="flex flex-col gap-4">
                                    @csrf
                                    @method('PATCH')

                                    <div class="flex flex-col">
                                        <x-input-label for="offense"
                                                       :value="__('Select Offense (Optional)')" />
                                        <select x-model="selectedOffense"
                                                @change="selectOffense()"
                                                class="bg-slate-800 text-white rounded p-2 text-sm">
                                            <option value="">Custom Sanction</option>
                                            @foreach ($rules as $ruleID => $rule)
                                            <optgroup label="{{ $rule['title'] }}">
                                                @foreach ($rule['escalations'] as $key => $sanction)
                                                <option value="{{ $ruleID }}.{{ $key }}">
                                                    Escalation {{ $key + 1 }}: {{ $sanction['type'] }}
                                                    @if(isset($sanction['duration_in_minutes']) && $sanction['duration_in_minutes'] > 0)
                                                    until {{ Carbon\Carbon::now()->addMinutes($sanction['duration_in_minutes'])->diffForHumans() }}
                                                    @endif
                                                </option>
                                                @endforeach
                                            </optgroup>
                                            @endforeach
                                        </select>
                                    </div>

                                    <div class="flex flex-col">
                                        <x-input-label for="type"
                                                       :value="__('Sanction Type')" />
                                        <select wire:model="type"
                                                x-model="sanctionType"
                                                class="bg-slate-800 text-white rounded p-2">
                                            <option value=""
                                                    disabled
                                                    selected>Select a sanction type</option>
                                            <option value="mute">Mute</option>
                                            <option value="kick">Kick</option>
                                            <option value="ban">Ban</option>
                                        </select>
                                        <x-input-error :messages="$errors->get('type')"
                                                       class="mt-2" />
                                    </div>

                                    <div class="flex flex-col">
                                        <x-input-label for="reason"
                                                       :value="__('Reason')" />
                                        <textarea wire:model="reason"
                                                  x-model="reason"
                                                  placeholder="Reason for sanction"
                                                  class="bg-slate-800 text-white rounded p-2 text-sm"
                                                  rows="3"></textarea>
                                        <x-input-error :messages="$errors->get('reason')"
                                                       class="mt-2" />
                                    </div>

                                    <div class="flex flex-col"
                                         x-show="sanctionType !== 'kick'">
                                        <x-input-label for="expires_at"
                                                       :value="__('Expires at (UTC)')" />
                                        <input type="datetime-local"
                                               wire:model="expires_at"
                                               x-model="expiresAt"
                                               class="bg-slate-800 text-white rounded p-2">
                                        <span class="text-xs text-gray-400 mt-1">Current UTC time: {{ now()->format('Y-m-d H:i') }}</span>
                                        <span class="text-xs text-yellow-400 mt-1"
                                              x-show="selectedOffense && offenseRules[selectedOffense] && offenseRules[selectedOffense].duration_in_minutes === -1">
                                            ⚠️ This is a permanent ban - no expiry date needed
                                        </span>
                                        <x-input-error :messages="$errors->get('expires_at')"
                                                       class="mt-2" />
                                    </div>

                                    <div class="flex gap-2">
                                        <x-danger-button type="submit"
                                                         class="flex-1">
                                            Apply Sanction
                                        </x-danger-button>
                                        <button type="button"
                                                @click="sanctioning = false"
                                                class="px-4 py-2 bg-slate-600 text-white rounded hover:bg-slate-500">
                                            Cancel
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <x-primary-button type="button"
                                          @click="sanctioning = !sanctioning">
                            Sanction
                        </x-primary-button>

                        <form method="POST"
                              wire:submit="moderate('{{ $chatLog->id }}')">
                            @csrf
                            @method('PATCH')

                            <x-primary-button type="submit"
                                              class="whitespace-nowrap">
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
