class CommonComponents::TagLabel < ViewComponent::Base
  def initialize(label:, img_src:)
    @label = label
    @img_src = img_src
  end
end
