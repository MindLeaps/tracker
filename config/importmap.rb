# Pin npm packages by running ./bin/importmap

pin 'jquery.slim', preload: true
pin 'awesomplete' # @1.1.5
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true

pin 'application', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin 'lodash.debounce', to: 'https://ga.jspm.io/npm:lodash.debounce@4.0.8/index.js'
pin 'pikaday'
