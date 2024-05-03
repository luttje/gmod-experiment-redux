<x-layouts.guest>
    <x-slot name="title">
        {{ __('Verify Email') }}
    </x-slot>

    <section class="rounded bg-slate-700 p-4 mb-4 flex flex-col gap-4 max-w-prose">
        <div class="mb-4 text-sm">
            {{ __('Thanks for signing up! Before getting started, could you verify your email address by clicking on the link we just emailed to you? If you didn\'t receive the email, we will gladly send you another.') }}
        </div>

        @if (session('status') == 'verification-link-sent')
            <div class="mb-4 font-medium text-sm text-green-600">
                {{ __('A new verification link has been sent to the email address you provided during registration.') }}
            </div>
        @endif

        <div class="mt-4 flex items-center justify-between">
            <form method="POST" action="{{ route('verification.send') }}">
                @csrf

                <div>
                    <x-primary-button>
                        {{ __('Resend Verification Email') }}
                    </x-primary-button>
                </div>
            </form>

            <form method="POST" action="{{ route('logout') }}">
                @csrf

                <x-primary-button type="submit">
                    Log Out
                </x-primary-button>
            </form>
        </div>
    </section>
</x-layouts.guest>
