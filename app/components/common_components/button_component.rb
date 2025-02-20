class CommonComponents::ButtonComponent < ViewComponent::Base
  include ApplicationHelper
  def initialize(label:, href: nil, options: {})
    @label = label
    @href = href
    @options = { type: 'button', class: 'normal-button' }.merge(options)
  end
end
