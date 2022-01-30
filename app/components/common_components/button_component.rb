# frozen_string_literal: true

class CommonComponents::ButtonComponent < ViewComponent::Base
  def initialize(label:, href:)
    @label = label
    @href = href
  end
end
