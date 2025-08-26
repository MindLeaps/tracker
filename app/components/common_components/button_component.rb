class CommonComponents::ButtonComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(label:, href: nil, options: {})
    @label = label
    @href = href
    @options = options.merge({ type: 'button', class: 'normal-button' })
  end
end
