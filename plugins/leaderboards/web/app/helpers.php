<?php

if (!function_exists('user')) {
    /**
     * Get the current user.
     *
     * @return \App\Models\User
     */
    function user()
    {
        return auth()->user();
    }
}
