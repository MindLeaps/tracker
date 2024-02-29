class AlertComponent < ViewComponent::Base
  def initialize(title:, text:)
    @title = title
    @text = text
  end
end
