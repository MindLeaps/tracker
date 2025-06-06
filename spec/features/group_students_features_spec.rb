require 'rails_helper'

RSpec.describe 'User interacts with students in Group', js: true do
  include_context 'login_with_global_admin'

  describe 'Viewing' do
    before :each do
      @group = create :group, group_name: 'Group One'
    end
  end

  describe 'Student creation and editing' do
    before :each do
      @group = create :group, group_name: 'Group One'
    end

    it 'renders error messages when student form is incomplete' do
      visit "/groups/#{@group.id}"

      click_button 'Create Student'

      expect(page).to have_content "Last name can't be blank"
      expect(page).to have_content "First name can't be blank"
      expect(page).to have_content "Dob can't be blank"
    end

    it 'renders a new student and updates when form is submitted' do
      visit "/groups/#{@group.id}"

      fill_in 'student_mlid', with: '12345678'
      fill_in 'student_last_name', with: 'Student'
      fill_in 'student_first_name', with: 'New'
      fill_in 'student_dob', with: '2024-01-01'
      find('#student_gender_nb').click
      click_button 'Create Student'

      expect(page).to have_content '12345678'
      expect(page).to have_content 'Student'
      expect(page).to have_content 'New'
      expect(page).to have_content 'NB'

      student = Student.find_by! first_name: 'New', last_name: 'Student'
      expect(student.gender).to eq('NB')

      click_link 'Edit'
      find("#student_#{student.id} #student_first_name").fill_in with: 'Updated'
      find("#student_#{student.id} #student_gender_m").click
      click_button 'Update Student'

      expect(page).to have_content 'Updated'
      expect(page).to have_content 'M'

      student.reload
      expect(student.first_name).to eq('Updated')
      expect(student.gender).to eq('M')
    end
  end
end
