# frozen_string_literal: true

class LayoutComponents::HeaderComponent < LayoutComponents::SidebarComponent
  def initialize(current_user:, title:)
    @current_user = current_user
    @title = title
  end
end
