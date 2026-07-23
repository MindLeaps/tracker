require 'rails_helper'

RSpec.describe CommonComponents::StatCard, type: :component do
  it 'renders the title and value' do
    render_inline(CommonComponents::StatCard.new(title: 'Number of active Chapters', value: 5))

    expect(page).to have_text('Number of active Chapters:')
    expect(page).to have_text('5')
  end
end
