# frozen_string_literal: true

class CommonComponents::Breadcrumbs < ViewComponent::Base
  include ApplicationHelper
  def initialize(current:, crumbs: [])
    @current = current
    @crumbs = crumbs
  end
end
