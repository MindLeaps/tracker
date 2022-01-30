# frozen_string_literal: true

class LayoutComponents::HeaderComponent < LayoutComponents::SidebarComponent
  def initialize(current_user:, title:, buttons: [])
    @current_user = current_user
    @title = title
    @buttons = buttons
  end
end
