class CommonComponents::TooltipComponent < ViewComponent::Base
  def initialize(label:, show: false)
    @label = label
    @show = show
  end
end
