require 'spec_helper'

RSpec.describe 'Grade Students' do
  it '', js: true do
    # Create a student
    visit '/'
    fill_in 'First name', with: 'Morty'
    fill_in 'Last name', with: 'Smith'
    click_button 'Create'

    expect(page).to have_content 'Smith'

    click_link 'Grading'
    expect(page).to have_content 'Memorization'

    click_button '3'
    expect(page).to have_content 'Student can recall at least 2 sections of the warm up from'
  end
end

