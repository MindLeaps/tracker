class CommonComponents::ToggleComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(id:, text:, is_toggled: true)
    @id = id
    @text = text
    @is_toggled = is_toggled
  end
end
