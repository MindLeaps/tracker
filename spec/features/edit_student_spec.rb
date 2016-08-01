require 'spec_helper'

RSpec.describe 'Edit Student' do
  it "Updates Rick's last name", js: true do
    visit '/'
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
