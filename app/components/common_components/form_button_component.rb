# frozen_string_literal: true

class CommonComponents::FormButtonComponent < ViewComponent::Base
  def initialize(label:, path: nil, method:)
    @label = label
    @path = path
    @method = method
  end
end
