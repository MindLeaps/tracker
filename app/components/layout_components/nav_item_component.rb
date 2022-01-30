# frozen_string_literal: true

class LayoutComponents::NavItemComponent < ViewComponent::Base
  def initialize(name:, url:, svg_icon: nil)
    @name = name
    @svg_icon = svg_icon
    @url = url
  end

  def before_render
    @is_active = current_page? @url
  end

  def disabled
    @is_active ? 'disabled="disabled"' : ''
  end

  def href
    @is_active ? '' : "href=#{@url}"
  end
end
