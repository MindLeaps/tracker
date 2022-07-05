# frozen_string_literal: true

class CommonComponents::FormButtonComponent < ViewComponent::Base
  def initialize(label:, method:, path: nil, params: nil)
    @label = label
    @path = path
    @method = method
    @params = params
  end
end
