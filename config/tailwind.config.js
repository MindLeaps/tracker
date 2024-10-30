const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*',
    './app/components/**/*.erb',
    './app/components/**/*.rb'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        'primary': 'rgb(107 33 168/var(--tw-bg-opacity))',
        'focus': 'rgb(22 163 74/var(--tw-bg-opacity))',
        'current': 'currentColor'
      },
      screens: {
        'print': { 'raw': 'print'}
      },
      variants: {
        stroke: ['hover']
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
