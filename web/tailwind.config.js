/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{vue,js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'card': {
          'red': '#dc2626',
          'black': '#1f2937'
        }
      }
    },
  },
  plugins: [],
}