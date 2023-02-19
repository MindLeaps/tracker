# frozen_string_literal: true

class CommonComponents::ButtonComponent < ViewComponent::Base
  include ApplicationHelper
  def initialize(label:, href: nil, attributes: '')
    @label = label
    @href = href
    @attributes = attributes
  end
end
