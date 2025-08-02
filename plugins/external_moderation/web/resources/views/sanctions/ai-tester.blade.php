<x-layouts.app with-alpine>
    <x-slot name="header">
        <h2 class="font-semibold text-xl leading-tight">
            {{ __('AI Testing') }}
        </h2>
    </x-slot>

    @php
        $rules = require app_path('Data/Rules.php');
    @endphp
    <div class="py-12"
    x-data="{
        name: '',
        description: '',
        message: '',
        rank: 'player',
        chat_type: 'ic',
        rules: {{ json_encode($rules) }},
    }">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">

            <!-- Character Name & Description Moderation Section -->
            <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
                <h3 class="text-lg font-semibold mb-4">Character Moderation Test</h3>

                <div x-data="{
                    loading: false,
                    result: null,
                    error: null,
                    async testCharacterModeration() {
                        if (!this.name.trim()) {
                            this.error = 'Character name is required';
                            return;
                        }

                        this.loading = true;
                        this.error = null;
                        this.result = null;

                        try {
                            const response = await fetch('{{ route('sanctions.ai-tester.character') }}', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                    'X-CSRF-TOKEN': document.querySelector('meta[name=csrf-token]').getAttribute('content')
                                },
                                body: JSON.stringify({
                                    name: this.name,
                                    description: this.description
                                })
                            });

                            if (!response.ok) {
                                throw new Error('Network response was not ok');
                            }

                            this.result = await response.json();
                        } catch (err) {
                            this.error = 'Error: ' + err.message;
                        } finally {
                            this.loading = false;
                        }
                    }
                }" class="space-y-4">

                    <!-- Character Name Input -->
                    <div>
                        <label for="char_name" class="block text-sm font-medium mb-2">
                            Character Name *
                        </label>
                        <input type="text"
                                x-model="name"
                                placeholder="Enter character name to test"
                                class="w-full bg-slate-700 text-white rounded p-3 text-sm border border-slate-600 focus:border-slate-500">
                    </div>

                    <!-- Character Description Input -->
                    <div>
                        <label for="char_description" class="block text-sm font-medium mb-2">
                            Character Description
                        </label>
                        <textarea x-model="description"
                                    placeholder="Enter character description to test"
                                    class="w-full bg-slate-700 text-white rounded p-3 text-sm border border-slate-600 focus:border-slate-500"
                                    rows="4"></textarea>
                    </div>

                    <!-- Test Button -->
                    <button @click="testCharacterModeration()"
                            :disabled="loading || !name.trim()"
                            class="w-full px-4 py-3 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:bg-slate-600 disabled:cursor-not-allowed font-medium">
                        <span x-show="!loading">Test Character Moderation</span>
                        <span x-show="loading" class="flex items-center justify-center">
                            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                            </svg>
                            Testing...
                        </span>
                    </button>

                    <!-- Error Display -->
                    <div x-show="error" x-text="error" class="p-3 bg-red-600/20 border border-red-500 rounded text-red-400 text-sm"></div>

                    <!-- Results Display -->
                    <div x-show="result" class="space-y-3">
                        <div class="p-4 bg-slate-700 rounded">
                            <h4 class="font-semibold mb-2">Moderation Result:</h4>

                            <!-- Overall Status -->
                            <div class="mb-3">
                                <span class="px-3 py-1 rounded text-sm font-medium"
                                        :class="result?.classification === 'ACCEPT' ? 'bg-green-600' : 'bg-red-600'">
                                        <span x-text="result?.classification === 'ACCEPT' ? 'ACCEPTED' : 'REJECTED'"></span>
                                </span>
                            </div>

                            <!-- Replacement Name -->
                            <div x-show="result?.replacement_name">
                                <strong class="text-sm">Replacement Name:</strong>
                                <p class="text-sm text-gray-300 mt-1" x-text="result?.replacement_name"></p>
                            </div>

                            <!-- Replacement Description -->
                            <div x-show="result?.replacement_description">
                                <strong class="text-sm">Replacement Description:</strong>
                                <p class="text-sm text-gray-300 mt-1" x-text="result?.replacement_description"></p>
                            </div>

                            <!-- Reasoning -->
                            <div x-show="result?.reason_to_user">
                                <strong class="text-sm">Reasoning (to user):</strong>
                                <p class="text-sm text-gray-300 mt-1" x-text="result?.reason_to_user"></p>
                            </div>

                            <!-- Raw JSON Toggle -->
                            <details class="mt-3">
                                <summary class="cursor-pointer text-sm text-gray-400 hover:text-white">Show Raw JSON</summary>
                                <pre class="mt-2 p-2 bg-slate-800 rounded text-xs overflow-auto" x-text="JSON.stringify(result, null, 2)"></pre>
                            </details>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Chat Content Moderation Section -->
            <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
                <h3 class="text-lg font-semibold mb-4">Chat Content Test</h3>

                <div x-data="{
                    loading: false,
                    result: null,
                    error: null,
                    async testChatModeration() {
                        if (!this.message.trim()) {
                            this.error = 'Chat message is required';
                            return;
                        }

                        this.loading = true;
                        this.error = null;
                        this.result = null;

                        try {
                            const response = await fetch('{{ route('sanctions.ai-tester.chat') }}', {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                    'X-CSRF-TOKEN': document.querySelector('meta[name=csrf-token]').getAttribute('content')
                                },
                                body: JSON.stringify({
                                    message: this.message,
                                    chat_type: this.chat_type,
                                    rank: this.rank
                                })
                            });

                            if (!response.ok) {
                                throw new Error('Network response was not ok');
                            }

                            this.result = await response.json();
                        } catch (err) {
                            this.error = 'Error: ' + err.message;
                        } finally {
                            this.loading = false;
                        }
                    }
                }" class="space-y-4">

                    <!-- Chat Message Input -->
                    <div>
                        <label for="chat_message" class="block text-sm font-medium mb-2">
                            Chat Message *
                        </label>
                        <textarea x-model="message"
                                    placeholder="Enter chat message to test for violations"
                                    class="w-full bg-slate-700 text-white rounded p-3 text-sm border border-slate-600 focus:border-slate-500"
                                    rows="4"></textarea>
                    </div>

                    <!-- Chat Type Selection -->
                    <div>
                        <label for="chat_type" class="block text-sm font-medium mb-2">
                            Chat Type *
                        </label>
                        <select x-model="chat_type"
                                class="w-full bg-slate-700 text-white rounded p-3 text-sm border border-slate-600 focus:border-slate-500">
                            <option value="ic">In-Character (IC)</option>
                            <option value="ooc">Out-of-Character (OOC)</option>
                            <option value="voice">Voice Chat</option>
                        </select>
                    </div>

                    <!-- Player Rank Selection -->
                    <div>
                        <label for="rank" class="block text-sm font-medium mb-2">
                            Player Rank *
                        </label>
                        <select x-model="rank"
                                class="w-full bg-slate-700 text-white rounded p-3 text-sm border border-slate-600 focus:border-slate-500">
                            <option value="player">Player</option>
                            <option value="admin">Admin</option>
                            <option value="superadmin">Super Admin</option>
                        </select>
                    </div>

                    <!-- Test Button -->
                    <button @click="testChatModeration()"
                            :disabled="loading || !message.trim() || !chat_type"
                            class="w-full px-4 py-3 bg-purple-600 text-white rounded hover:bg-purple-700 disabled:bg-slate-600 disabled:cursor-not-allowed font-medium">
                        <span x-show="!loading">Test Chat Moderation</span>
                        <span x-show="loading" class="flex items-center justify-center">
                            <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                            </svg>
                            Testing...
                        </span>
                    </button>

                    <!-- Error Display -->
                    <div x-show="error" x-text="error" class="p-3 bg-red-600/20 border border-red-500 rounded text-red-400 text-sm"></div>

                    <!-- Results Display -->
                    <div x-show="result" class="space-y-3">
                        <div class="p-4 bg-slate-700 rounded">
                            <h4 class="font-semibold mb-2">Moderation Result:</h4>

                            <!-- Violation Status -->
                            <div class="mb-3">
                                <span class="px-3 py-1 rounded text-sm font-medium"
                                        :class="result?.classification === 'VIOLATION' ? 'bg-red-600' : (result?.classification === 'FLAGGED' ? 'bg-yellow-600' : 'bg-green-600')">
                                    <span x-text="result?.classification === 'VIOLATION' ? 'VIOLATION' : (result?.classification === 'FLAGGED' ? 'FLAGGED' : 'SAFE')"></span>
                                </span>
                            </div>


                            <!-- Rule Violations -->
                            <div x-show="result?.rule_id" class="mb-3">
                                <strong class="text-sm">Rule Violation:</strong>
                                <p class="text-sm text-gray-300 mt-1" x-text="rules[result?.rule_id]?.title"></p>
                            </div>

                            <!-- Reasoning -->
                            <div x-show="result?.reasoning">
                                <strong class="text-sm">Reasoning:</strong>
                                <p class="text-sm text-gray-300 mt-1" x-text="result?.reasoning"></p>
                            </div>

                            <!-- Raw JSON Toggle -->
                            <details class="mt-3">
                                <summary class="cursor-pointer text-sm text-gray-400 hover:text-white">Show Raw JSON</summary>
                                <pre class="mt-2 p-2 bg-slate-800 rounded text-xs overflow-auto" x-text="JSON.stringify(result, null, 2)"></pre>
                            </details>
                        </div>
                    </div>
                </div>
            </section>
        </div>

        <!-- Quick Test Examples -->
        <div class="mt-8 bg-slate-800 overflow-hidden shadow-sm sm:rounded-lg">
            <div class="p-6">
                <h3 class="text-lg font-semibold mb-4">Quick Test Examples</h3>

                <div class="text-xs text-gray-400 mb-4">
                    Click on any example to populate the respective test section with that content.
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Character Examples -->
                    <div>
                        <h4 class="font-medium mb-3 text-blue-400">Character Test Examples:</h4>
                        <div class="space-y-2 text-sm">
                            <div class="p-2 bg-slate-700 rounded cursor-pointer hover:bg-slate-600"
                                    @click="name = 'John Smith'">
                                <strong>Valid:</strong> John Smith
                            </div>
                            <div class="p-2 bg-slate-700 rounded cursor-pointer hover:bg-slate-600"
                                    @click="name = 'Prrrtt shitmans'; description = 'A character who is a shitman, he is a shitman and he does shitman things.'">
                                <strong>Invalid:</strong> Prrrtt shitmans + inappropriate description
                            </div>
                            <div class="p-2 bg-slate-700 rounded cursor-pointer hover:bg-slate-600"
                                    @click="name = 'Adolf Hitler'; description = 'A historical figure known for his role in World War II.'">
                                <strong>Invalid:</strong> Adolf Hitler
                            </div>
                        </div>
                    </div>

                    <!-- Chat Examples -->
                    <div>
                        <h4 class="font-medium mb-3 text-purple-400">Chat Test Examples:</h4>
                        <div class="space-y-2 text-sm">
                            <div class="p-2 bg-slate-700 rounded cursor-pointer hover:bg-slate-600"
                                    @click="message = 'Hello, how are you?'; chat_type = 'ooc'">
                                <strong>Valid:</strong> (OOC) "Hello, how are you?"
                            </div>
                            <div class="p-2 bg-slate-700 rounded cursor-pointer hover:bg-slate-600"
                                    @click="message = 'You fucking idiot, go kill yourself!'; chat_type = 'ic'">
                                <strong>Violation:</strong> (IC) "You fucking idiot, go kill yourself!"
                            </div>
                            <div class="p-2 bg-slate-700 rounded cursor-pointer hover:bg-slate-600"
                                    @click="message = 'Anyone want to buy some drugs? I have cocaine for sale.'; chat_type = 'ic'">
                                <strong>Flagged:</strong> (IC) "Anyone want to buy some drugs? I have cocaine for sale."
                            </div>
                            <div class="p-2 bg-slate-700 rounded cursor-pointer hover:bg-slate-600"
                                    @click="message = 'I have a great idea for a new game!'; chat_type = 'ooc'">
                                <strong>Valid:</strong> (OOC) "I have a great idea for a new game!"
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4">
        <h3 class="text-lg font-semibold">AI System Prompt Designer <small>(Dev tool)</small></h3>
        @php
            $promptInfo = require app_path('Data/PromptChatModeration.php');
        @endphp
        <pre class="bg-gray-800 p-4 rounded whitespace-pre-wrap">{{ $promptInfo['prompt'] }}</pre>
    </section> --}}

    <script>
        // Add references to sections for the quick examples
        document.addEventListener('alpine:init', () => {
            const charSection = document.querySelector('.grid > div:first-child');
            const chatSection = document.querySelector('.grid > div:last-child');

            if (charSection) charSection.setAttribute('x-ref', 'charTestSection');
            if (chatSection) chatSection.setAttribute('x-ref', 'chatTestSection');
        });
    </script>
</x-layouts.app>
