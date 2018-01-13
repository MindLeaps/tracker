# frozen_string_literal: true

Slim::Engine.set_options shortcut: { '#' => { attr: 'id' }, '.' => { attr: 'class' } }
