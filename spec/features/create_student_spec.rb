# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create student' do
  before :each do
    create :organization
  end
  include_context 'login_with_global_admin'

  it 'creates Rick', js: true do
    visit '/students'
    click_link 'Add Student'
    fill_in 'MLID', with: '1A'
    fill_in 'First name', with: 'Rick'
    fill_in 'Last name', with: 'Sanchez'
    click_button 'Create'

    expect(page).to have_content 'Rick'
    expect(page).to have_content 'Sanchez'
    expect(page).to have_content 'Student "Sanchez, Rick" created.'
    expect(page).to have_link 'Create another', href: new_student_path
  end
end
