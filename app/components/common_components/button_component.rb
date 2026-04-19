class CommonComponents::ButtonComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(label:, href: nil, options: {})
    @label = label
    @href = href
    classes = options[:class].presence || 'normal-button'
    @options = options.merge(type: 'button', class: classes)
  end
end
