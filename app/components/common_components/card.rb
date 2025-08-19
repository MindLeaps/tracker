class CommonComponents::Card < ViewComponent::Base
  renders_one :card_content

  def initialize(title:)
    @title = title
  end
end
