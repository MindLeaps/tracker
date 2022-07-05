# frozen_string_literal: true

class CommonComponents::Breadcrumbs < ViewComponent::Base
  def initialize(current:, crumbs: [])
    @current = current
    @crumbs = crumbs
  end
end
