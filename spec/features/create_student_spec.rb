require 'rails_helper'

RSpec.describe 'Create student' do
  before :all do
    create :organization
  end
  include_context 'login_with_admin'

  it 'creates Rick', js: true do
    visit '/students'
    click_link 'New Student'
    fill_in 'First name', with: 'Rick'
    fill_in 'Last name', with: 'Sanchez'
    click_button 'Create'

    expect(page).to have_content 'Rick'
    expect(page).to have_content 'Sanchez'
    expect(page).to have_content 'Student "Sanchez, Rick" successfully created'
  end
end
