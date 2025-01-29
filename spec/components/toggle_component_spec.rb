require 'rails_helper'

RSpec.describe CommonComponents::ToggleComponent, type: :component do
  it 'renders as toggled' do
    render_inline(CommonComponents::ToggleComponent.new(id: 'Some Id', text: 'Some text'))
    expect(page).to have_css('button[data-toggled="true"]')
  end

  it 'renders as untoggled' do
    render_inline(CommonComponents::ToggleComponent.new(id: 'Some Id', text: 'Some text', is_toggled: false))
    expect(page).to_not have_css('button[data-toggled="true"]')
  end
end
