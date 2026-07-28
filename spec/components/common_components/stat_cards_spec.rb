require 'rails_helper'

RSpec.describe CommonComponents::StatCards, type: :component do
  it 'renders a stat card for each stat' do
    render_inline(CommonComponents::StatCards.new(columns: 2, stats: [{ title: 'Number of active Chapters', value: 5 }, { title: 'Number of active Groups', value: 2 }]))

    expect(page).to have_text('Number of active Chapters:')
    expect(page).to have_text('5')
    expect(page).to have_text('Number of active Groups:')
    expect(page).to have_text('2')
  end

  it 'does not render a label when none is given' do
    render_inline(CommonComponents::StatCards.new(columns: 2, stats: [{ title: 'Number of active Chapters', value: 5 }]))

    expect(page).not_to have_selector('h2')
  end

  it 'renders the label when given' do
    render_inline(CommonComponents::StatCards.new(label: 'Overview', columns: 2, stats: [{ title: 'Number of active Chapters', value: 5 }]))

    expect(page).to have_text('Overview')
  end
end
