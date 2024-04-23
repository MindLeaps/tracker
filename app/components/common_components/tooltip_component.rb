class CommonComponents::TooltipComponent < ViewComponent::Base
  def initialize(text:)
    @text = text
  end
end
