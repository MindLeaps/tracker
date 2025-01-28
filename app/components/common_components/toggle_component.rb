class CommonComponents::ToggleComponent < ViewComponent::Base
  include ApplicationHelper
  def initialize(id:, text:)
    @id = id
    @text = text
  end
end
