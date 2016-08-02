require 'rails_helper'

RSpec.describe 'Edit student' do
  include_context 'login'

  it 'creates Rick', js: true do
    visit '/students'
    fill_in 'First name', with: 'Rick'
    fill_in 'Last name', with: 'Zehcnas'
    click_button 'Create'

    click_link 'Zehcnas'
    click_link 'Edit'
    fill_in 'Last name', with: 'Sanchez'
    click_button 'Update'

    expect(page).to have_content 'Rick'
    expect(page).to have_content 'Sanchez'
  end
end
