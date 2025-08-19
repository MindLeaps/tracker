class CommonComponents::Breadcrumbs < ViewComponent::Base
  include ApplicationHelper

  def initialize(current: nil, crumbs: [])
    @current = current
    @crumbs = crumbs
  end
end
