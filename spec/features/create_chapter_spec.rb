require 'rails_helper'

RSpec.describe 'Create chapter' do
  include_context 'login'

  it 'creates Kigali Chapter', js: true do
    visit '/chapters'
    fill_in 'Chapter name', with: 'Kigali'
    click_button 'Create'

    expect(page).to have_content 'Kigali'
  end
end
