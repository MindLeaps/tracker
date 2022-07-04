# frozen_string_literal: true

class LayoutComponents::HeaderComponent < LayoutComponents::SidebarComponent
  renders_one :left
  def initialize(current_user:, tabs:, title: '', buttons: [])
    @current_user = current_user
    @tabs = tabs
    @title = title
    @buttons = buttons
  end
end
