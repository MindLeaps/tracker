# frozen_string_literal: true

class CommonComponents::EditButton < ViewComponent::Base
  def initialize(identifier:, path:, tooltip_content:)
    @identifier = identifier
    @path = path
    @tooltip_content = tooltip_content
  end
end
