<x-layouts.guest>
    <x-slot name="title">
        Login
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4 max-w-prose">
        <!-- Session Status -->
        <x-auth-session-status class="mb-4" :status="session('status')" />

        <form method="POST" action="{{ route('login') }}">
            @csrf

            <!-- Email Address -->
            <div>
                <x-input-label for="email" :value="__('Email')" />
                <x-text-input id="email" class="block mt-1 w-full" type="email" name="email" :value="old('email')" required autofocus autocomplete="username" />
                <x-input-error :messages="$errors->get('email')" class="mt-2" />
            </div>

            <!-- Password -->
            <div class="mt-4">
                <x-input-label for="password" :value="__('Password')" />

                <x-text-input id="password" class="block mt-1 w-full"
                                type="password"
                                name="password"
                                required autocomplete="current-password" />

                <x-input-error :messages="$errors->get('password')" class="mt-2" />
            </div>

            <!-- Remember Me -->
            <div class="block mt-4">
                <label for="remember_me" class="inline-flex items-center">
                    <input id="remember_me" type="checkbox" class="rounded border-gray-300 text-indigo-600 shadow-sm focus:ring-brand-600" name="remember">
                    <span class="ms-2 text-sm">{{ __('Remember me') }}</span>
                </label>
            </div>

            <div class="flex items-center justify-end gap-2 mt-4">
                <a class="underline text-sm hover:rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-600" href="{{ route('register') }}">
                    {{ __('Have an invite code?') }}
                </a>

                @if (Route::has('password.request'))
                    <a class="underline text-sm hover:rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-brand-600" href="{{ route('password.request') }}">
                        {{ __('Forgot your password?') }}
                    </a>
                @endif

                <x-primary-button>
                    {{ __('Log in') }}
                </x-primary-button>
            </div>
        </form>
    </section>
</x-layouts.guest>
