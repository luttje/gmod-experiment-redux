<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\InviteCode;
use App\Models\User;
use Illuminate\Auth\Events\Registered;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;
use Illuminate\View\View;

class RegisteredUserController extends Controller
{
    /**
     * Display the registration view.
     */
    public function create(): View
    {
        return view('auth.register');
    }

    /**
     * Handle an incoming registration request.
     *
     * @throws \Illuminate\Validation\ValidationException
     */
    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'lowercase', 'email', 'max:255', 'unique:'.User::class],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
            'invite_code' => ['required', 'string', 'exists:invite_codes,code'],
        ]);

        return DB::transaction(function () use ($request) {
            $inviteCode = InviteCode::where('code', $request->invite_code)->first();

            if ($inviteCode->user_id !== null) {
                return redirect()
                    ->back()
                    ->withInput()
                    ->withErrors([
                    'invite_code' => 'This invite code has already been used.',
                ]);
            }

            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
            ]);

            $inviteCode->update([
                'user_id' => $user->id,
            ]);

            event(new Registered($user));

            Auth::login($user);

            return redirect(route('dashboard', absolute: false));
        });
    }
}
