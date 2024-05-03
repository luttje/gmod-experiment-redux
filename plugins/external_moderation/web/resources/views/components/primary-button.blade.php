<button {{ $attributes->merge(['type' => 'submit', 'class' => 'inline-flex items-center px-4 py-2 bg-gray-800 border border-transparent rounded-md font-semibold text-xs text-white uppercase tracking-widest hover:bg-brand-500 focus:bg-gray-700 active:bg-gray-900 focus:outline-none focus:ring-2 focus:ring-brand-600 focus:ring-offset-2 transition ease-in-out duration-150']) }}>
    {{ $slot }}
</button>
