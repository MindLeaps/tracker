# frozen_string_literal: true

class CommonComponents::Card < ViewComponent::Base
  renders_one :card_content

  def initialize(title:)
    super
    @title = title
  end
end
