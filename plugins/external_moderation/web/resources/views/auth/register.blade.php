<x-layouts.guest>
    <x-slot name="title">
        {{ __('Register') }}
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4 max-w-prose">
        <form method="POST" action="{{ route('register') }}">
            @csrf

            <div>
                <x-input-label for="name" :value="__('Name')" />
                <x-text-input id="name" class="block mt-1 w-full" type="text" name="name" :value="old('name')" required autofocus autocomplete="name" />
                <x-input-error :messages="$errors->get('name')" class="mt-2" />
            </div>

            <div class="mt-4">
                <x-input-label for="email" :value="__('Email')" />
                <x-text-input id="email" class="block mt-1 w-full" type="email" name="email" :value="old('email')" required autocomplete="username" />
                <x-input-error :messages="$errors->get('email')" class="mt-2" />
            </div>

            <div class="mt-4">
                <x-input-label for="password" :value="__('Password')" />

                <x-text-input id="password" class="block mt-1 w-full"
                                type="password"
                                name="password"
                                required autocomplete="new-password" />

                <x-input-error :messages="$errors->get('password')" class="mt-2" />
            </div>

            <div class="mt-4">
                <x-input-label for="password_confirmation" :value="__('Confirm Password')" />

                <x-text-input id="password_confirmation" class="block mt-1 w-full"
                                type="password"
                                name="password_confirmation" required autocomplete="new-password" />

                <x-input-error :messages="$errors->get('password_confirmation')" class="mt-2" />
            </div>

            <div class="mt-4">
                <x-input-label for="invite_code" :value="__('Invite Code')" />

                <x-text-input id="invite_code" class="block mt-1 w-full"
                                type="text"
                                name="invite_code"
                                required />

                <x-input-error :messages="$errors->get('invite_code')" class="mt-2" />
            </div>

            <div class="flex items-center justify-end mt-4">
                <a class="underline text-sm hover:rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-600" href="{{ route('login') }}">
                    {{ __('Already registered?') }}
                </a>

                <x-primary-button class="ms-4">
                    {{ __('Register') }}
                </x-primary-button>
            </div>
        </form>
    </section>
</x-layouts.guest>
