@props(['disabled' => false])

<input {{ $disabled ? 'disabled' : '' }} {!! $attributes->merge(['class' => 'border-gray-300 focus:border-brand-600 focus:ring-brand-600 rounded-md shadow-sm text-slate-900']) !!}>
