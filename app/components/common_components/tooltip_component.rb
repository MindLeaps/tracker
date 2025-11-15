class CommonComponents::TooltipComponent < ViewComponent::Base
  def initialize(text:, custom_class: nil)
    @text = text
    @custom_class = custom_class
  end
end
