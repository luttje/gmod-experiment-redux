<x-layouts.guest>
    <x-slot name="title">
        {{ __('Confirm Password') }}
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4 max-w-prose">
        <div class="mb-4 text-sm">
            {{ __('This is a secure area of the application. Please confirm your password before continuing.') }}
        </div>

        <form method="POST" action="{{ route('password.confirm') }}">
            @csrf

            <!-- Password -->
            <div>
                <x-input-label for="password" :value="__('Password')" />

                <x-text-input id="password" class="block mt-1 w-full"
                                type="password"
                                name="password"
                                required autocomplete="current-password" />

                <x-input-error :messages="$errors->get('password')" class="mt-2" />
            </div>

            <div class="flex justify-end mt-4">
                <x-primary-button>
                    {{ __('Confirm') }}
                </x-primary-button>
            </div>
        </form>
    </section>
</x-layouts.guest>
