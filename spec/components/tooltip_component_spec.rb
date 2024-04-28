require 'rails_helper'

RSpec.describe CommonComponents::TooltipComponent, type: :component do
  it 'renders but does not show' do
    result = render_inline(CommonComponents::TooltipComponent.new(text: 'Some text')).at_css('div')[:class]

    expect(result).to include('tooltip')
    expect(result).to include('hidden')
  end
end
