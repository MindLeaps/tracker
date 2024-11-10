require 'rails_helper'

RSpec.describe 'User interacts with students in Group' do
  include_context 'login_with_global_admin'

  describe 'Viewing' do
    it 'displays a list of students with a form to create new ones', js: true do
      @group = create :group, group_name: 'Group One'
      visit "/groups/#{@group.id}"

      expect(page).to have_content 'Create Student'

      expect(page).to have_content 'Students currently enrolled in this group'
      expect(page).to have_content '#new-student-form'
    end
  end

  describe 'Student creation' do
    before :each do
      @group = create :group, group_name: 'Group One'
    end

    it 'renders error messages when student form is incomplete', js: true do
      visit "/groups/#{@group.id}"

      expect(page).to have_content 'Create Student'
      click_button 'Create Student'

      expect(page).to have_content "MLID can't be blank"
      expect(page).to have_content 'MLID No special characters allowed in MLID'
      expect(page).to have_content 'MLID No special characters allowed in MLID'
      expect(page).to have_content 'MLID No special characters allowed in MLID'
      expect(page).to have_content "Last name can't be blank"
      expect(page).to have_content "First name can't be blank"
    end
  end
end
