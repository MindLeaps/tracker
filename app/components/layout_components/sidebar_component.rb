class LayoutComponents::SidebarComponent < ViewComponent::Base
  def initialize(current_user:)
    @current_user = current_user
  end
end
