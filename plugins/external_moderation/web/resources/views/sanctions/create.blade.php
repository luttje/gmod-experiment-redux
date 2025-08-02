<x-layouts.app with-alpine>
    <x-slot name="header">
        <h2 class="font-semibold text-xl leading-tight">
            {{ __('Apply Sanction') }}
        </h2>
    </x-slot>

    <div class="py-12">
        <div class="max-w-4xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-slate-800 overflow-hidden shadow-sm sm:rounded-lg">
                <div class="p-6">
                    <!-- Chat Log Details -->
                    <div class="mb-8 p-4 bg-slate-700 rounded">
                        <h3 class="text-lg font-semibold mb-3">Chat Log Details</h3>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <strong>Character:</strong> {{ $chatLog->character_name }}
                            </div>
                            <div>
                                <strong>Steam Name:</strong> {{ $chatLog->steam_name }}
                            </div>
                            <div>
                                <strong>Type:</strong>
                                @if($chatLog->isVoiceChat())
                                    Voice Chat
                                @else
                                    {{ strtoupper($chatLog->chat_type) }}
                                @endif
                            </div>
                            <div>
                                <strong>Received:</strong> {{ $chatLog->created_at->diffForHumans() }}
                            </div>
                        </div>
                        @if($chatLog->message)
                            <div class="mt-3">
                                <strong>Message:</strong>
                                <div class="bg-slate-600 p-3 rounded mt-1">
                                    {{ $chatLog->message }}
                                </div>
                            </div>
                        @endif
                    </div>

                    <!-- Previous Sanctions -->
                    @if($previousSanctions->count() > 0)
                        <div class="mb-8 p-4 bg-slate-700 rounded">
                            <h3 class="text-lg font-semibold mb-3">Previous Sanctions ({{ $previousSanctions->count() }})</h3>
                            <div class="space-y-3">
                                @foreach($previousSanctions as $sanction)
                                    <div class="bg-slate-600 p-3 rounded flex justify-between items-start">
                                        <div class="flex-1">
                                            <div class="flex items-center gap-2 mb-1">
                                                <span class="px-2 py-1 rounded text-xs font-medium
                                                    @if($sanction->type === 'mute') bg-yellow-600
                                                    @elseif($sanction->type === 'kick') bg-orange-600
                                                    @elseif($sanction->type === 'ban') bg-red-600
                                                    @endif">
                                                    {{ strtoupper($sanction->type) }}
                                                </span>
                                                @if($sanction->rule_id)
                                                    @php
                                                        $ruleDetails = $sanction->getRuleDetails();
                                                    @endphp
                                                    @if($ruleDetails)
                                                        <span class="text-xs text-gray-400">
                                                            {{ $ruleDetails['rule']['title'] }} - Escalation {{ $sanction->escalation_level + 1 }}
                                                        </span>
                                                    @endif
                                                @endif
                                            </div>
                                            <div class="text-sm">{{ $sanction->reason }}</div>
                                            @if($sanction->expires_at)
                                                <div class="text-xs text-gray-400 mt-1">
                                                    @if($sanction->isActive())
                                                        Expires: {{ $sanction->expires_at->diffForHumans() }}
                                                    @else
                                                        Expired: {{ $sanction->expires_at->diffForHumans() }}
                                                    @endif
                                                </div>
                                            @endif
                                        </div>
                                        <div class="text-xs text-right flex flex-col justify-between self-stretch">
                                            {{ $sanction->created_at->format('M j, Y') }}
                                            <div>
                                                @if($sanction->issued_by)
                                                    <span class="text-gray-400">Issued by:</span>
                                                    <span class="font-semibold">{{ $sanction->issuer->name }}</span>
                                                @else
                                                    <span class="italic text-gray-400">Issued by AI</span>
                                                @endif
                                            </div>
                                        </div>
                                    </div>
                                @endforeach
                            </div>
                        </div>
                    @endif

                    <!-- Sanction Form -->
                    <div class="bg-slate-700 p-4 rounded">
                        <h3 class="text-lg font-semibold mb-4">Apply New Sanction</h3>

                        <form method="POST" action="{{ route('sanctions.store', $chatLog) }}"
                              x-data="{
                                  selectedOffense: '',
                                  sanctionType: '',
                                  reason: '',
                                  expiresAt: '',
                                  ruleId: '',
                                  escalationLevel: '',
                                  offenseRules: {{ json_encode($rulesWithEscalations) }},
                                  calculateExpiryTime(minutes) {
                                      if (minutes === -1) return ''; // Permanent ban
                                      if (minutes === 0) return ''; // Kick (no expiry needed)

                                      const now = new Date();
                                      const expiry = new Date(now.getTime() + (minutes * 60000));
                                      return expiry.toISOString().slice(0, 16);
                                  },
                                  selectOffense() {
                                      if (!this.selectedOffense) {
                                          this.clearForm();
                                          return;
                                      }

                                      const [ruleID, escalationID] = this.selectedOffense.split('.');

                                      if (this.offenseRules[ruleID]) {
                                          const rule = this.offenseRules[ruleID];
                                          const escalation = rule.rule.escalations[escalationID];

                                          this.sanctionType = escalation.type;
                                          this.reason = escalation.reason;
                                          this.expiresAt = this.calculateExpiryTime(escalation.duration_in_minutes);
                                          this.ruleId = ruleID;
                                          this.escalationLevel = escalationID;
                                      }
                                  },
                                  clearForm() {
                                      this.sanctionType = '';
                                      this.reason = '';
                                      this.expiresAt = '';
                                      this.ruleId = '';
                                      this.escalationLevel = '';
                                  }
                              }"
                              class="space-y-4">
                            @csrf

                            <!-- Rule Selection -->
                            <div>
                                <label for="offense" class="block text-sm font-medium mb-2">
                                    Select Rule Violation (Optional)
                                </label>
                                <select x-model="selectedOffense"
                                        @change="selectOffense()"
                                        class="w-full bg-slate-800 text-white rounded p-3 text-sm">
                                    <option value="">Custom Sanction (No Rule)</option>
                                    @foreach($rulesWithEscalations as $ruleId => $ruleData)
                                        <optgroup label="{{ $ruleData['rule']['title'] }} ({{ $ruleData['offense_count'] }} previous offense{{ $ruleData['offense_count'] !== 1 ? 's' : '' }})">
                                            @foreach($ruleData['escalations'] as $escalationIndex => $escalation)
                                                <option value="{{ $ruleId }}.{{ $escalationIndex }}"
                                                        @if($escalation['is_used']) class="text-gray-500" @endif>
                                                        &nbsp&nbsp
                                                    @if($escalation['is_used'])
                                                        ✓
                                                    @elseif($escalationIndex === $ruleData['next_escalation_level'])
                                                        →
                                                    @endif
                                                    Escalation {{ $escalationIndex + 1 }}: {{ $escalation['type'] }}
                                                    @if(isset($escalation['duration_in_minutes']) && $escalation['duration_in_minutes'] > 0)
                                                        ({{ $escalation['duration_in_minutes'] }} min)
                                                    @elseif(isset($escalation['duration_in_minutes']) && $escalation['duration_in_minutes'] === -1)
                                                        (Permanent)
                                                    @endif
                                                </option>
                                            @endforeach
                                        </optgroup>
                                    @endforeach
                                </select>
                                <div class="text-xs text-gray-400 mt-1">
                                    ✓ = Already used, → = Next recommended escalation
                                </div>
                            </div>

                            <!-- Hidden fields for rule tracking -->
                            <input type="hidden" name="rule_id" x-model="ruleId">
                            <input type="hidden" name="escalation_level" x-model="escalationLevel">

                            <!-- Sanction Type -->
                            <div>
                                <label for="type" class="block text-sm font-medium mb-2">
                                    Sanction Type *
                                </label>
                                <select name="type" x-model="sanctionType" required
                                        class="w-full bg-slate-800 text-white rounded p-3">
                                    <option value="">Select sanction type</option>
                                    <option value="mute">Mute</option>
                                    <option value="kick">Kick</option>
                                    <option value="ban">Ban</option>
                                </select>
                                @error('type')
                                    <div class="text-red-400 text-sm mt-1">{{ $message }}</div>
                                @enderror
                            </div>

                            <!-- Reason -->
                            <div>
                                <label for="reason" class="block text-sm font-medium mb-2">
                                    Reason *
                                </label>
                                <textarea name="reason" x-model="reason" required
                                          placeholder="Reason for sanction"
                                          class="w-full bg-slate-800 text-white rounded p-3 text-sm"
                                          rows="3"></textarea>
                                @error('reason')
                                    <div class="text-red-400 text-sm mt-1">{{ $message }}</div>
                                @enderror
                            </div>

                            <!-- Expiry Date -->
                            <div x-show="sanctionType !== 'kick'">
                                <label for="expires_at" class="block text-sm font-medium mb-2">
                                    Expires At (UTC)
                                </label>
                                <input type="datetime-local" name="expires_at" x-model="expiresAt"
                                       class="w-full bg-slate-800 text-white rounded p-3">
                                <div class="text-xs text-gray-400 mt-1">
                                    Current UTC time: {{ now()->format('Y-m-d H:i') }}
                                </div>
                                <div class="text-xs text-yellow-400 mt-1" x-show="expiresAt === ''">
                                    ⚠️ No expiry date = permanent sanction
                                </div>
                                @error('expires_at')
                                    <div class="text-red-400 text-sm mt-1">{{ $message }}</div>
                                @enderror
                            </div>

                            <!-- Action Buttons -->
                            <div class="flex gap-4 pt-4">
                                <button type="submit"
                                        class="px-6 py-3 bg-red-600 text-white rounded hover:bg-red-700 font-medium">
                                    Apply Sanction
                                </button>
                                <a href="{{ route('chat-logs.moderation') }}"
                                   class="px-6 py-3 bg-slate-600 text-white rounded hover:bg-slate-500 font-medium">
                                    Cancel
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</x-layouts.app>
