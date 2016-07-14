require 'spec_helper'

RSpec.describe 'Create student' do
  it 'creates Rick', js: true do
    visit '/students'
    fill_in 'First name', with: 'Rick'
    fill_in 'Last name', with: 'Sanchez'
    click_button 'Create'

    expect(page).to have_content 'Rick'
    expect(page).to have_content 'Sanchez'
  end
end
