class LayoutComponents::HeaderComponent < LayoutComponents::SidebarComponent
  include ApplicationHelper

  renders_one :left
  def initialize(current_user:, tabs:, buttons: [])
    @current_user = current_user
    @tabs = tabs
    @buttons = buttons
  end
end
