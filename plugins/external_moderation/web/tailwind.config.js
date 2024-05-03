import defaultTheme from 'tailwindcss/defaultTheme';
import forms from '@tailwindcss/forms';

/** @type {import('tailwindcss').Config} */
export default {
    content: [
        './vendor/laravel/framework/src/Illuminate/Pagination/resources/views/*.blade.php',
        './storage/framework/views/*.php',
        './resources/views/**/*.blade.php',
    ],

    theme: {
        extend: {
            fontFamily: {
                sans: ['Figtree', ...defaultTheme.fontFamily.sans],
            },
            colors: {
                brand: {
                    '50': '#fdf4f3',
                    '100': '#fce7e4',
                    '200': '#fad3ce',
                    '300': '#f5b4ac',
                    '400': '#ed897c',
                    '500': '#e26151',
                    '600': '#ce4534',
                    '700': '#a33426',
                    '800': '#8f3125',
                    '900': '#772e25',
                    '950': '#40140f',
                },
            },
        },
    },

    plugins: [forms],
};
