# frozen_string_literal: true

class NavItemComponent < ViewComponent::Base
  def initialize(name:, svg_icon:, url:)
    @name = name
    @svg_icon = svg_icon
    @url = url
  end

  def before_render
    @is_active = current_page? @url
  end

  def nav_link_class
    "mdl-navigation__link nav-link#{@is_active ? ' mdl-navigation__link--current' : ' mdl-js-button mdl-js-ripple-effect'}"
  end

  def disabled
    @is_active ? 'disabled="disabled"' : ''
  end

  def href
    @is_active ? '' : "href=#{@url}"
  end
end
