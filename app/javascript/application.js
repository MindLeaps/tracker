// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import jQuery from 'jquery.slim'
import "@hotwired/turbo-rails"

window.$ = jQuery
window.jQuery = jQuery

import 'material-design-lite'
import 'mdl-selectfield'
import 'awesomplete'

import 'controllers'
// we don't want to enable turbo drive just yet until we finish the redesign
// Turbo.session.drive = false;