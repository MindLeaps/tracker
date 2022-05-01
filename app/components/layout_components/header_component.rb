# frozen_string_literal: true

class LayoutComponents::HeaderComponent < LayoutComponents::SidebarComponent
  def initialize(current_user:, tabs:, buttons: [])
    @current_user = current_user
    @tabs = tabs
    @buttons = buttons
  end
end
