require 'rails_helper'

RSpec.describe 'User interacts with students in Group', js: true do
  include_context 'login_with_global_admin'

  describe 'Viewing' do
    before :each do
      @group = create :group, group_name: 'Group One'
    end

    it 'displays a list of students with a form to create new ones' do
      visit "/groups/#{@group.id}"

      expect(page).to have_selector("#new-student-form")
      expect(page).to have_content 'Students currently enrolled in this group'
    end
  end

  describe 'Student creation and editing' do
    before :each do
      @group = create :group, group_name: 'Group One'
    end

    it 'renders error messages when student form is incomplete' do
      visit "/groups/#{@group.id}"

      click_button 'Create Student'

      expect(page).to have_content "MLID can't be blank"
      expect(page).to have_content "Last name can't be blank"
      expect(page).to have_content "First name can't be blank"
    end

    it 'renders new student when form is submitted' do
      visit "/groups/#{@group.id}"

      fill_in 'student_mlid', with: '1A'
      fill_in 'student_last_name', with: 'Student'
      fill_in 'student_first_name', with: 'New'
      find('#student_gender_nb').click
      click_button 'Create Student'

      expect(page).to have_content "#{@group.full_mlid}-1A"
      expect(page).to have_content 'Student'
      expect(page).to have_content 'New'
      expect(page).to have_content 'NB'

      created_student = Student.find_by! first_name: 'New', last_name: 'Student'
      expect(created_student.gender).to eq('NB')
    end

    it 'renders updated student when edit form is submitted' do
      visit "/groups/#{@group.id}"

      fill_in 'student_mlid', with: '1A'
      fill_in 'student_last_name', with: 'Student'
      fill_in 'student_first_name', with: 'New'
      find('#student_gender_nb').click

      click_button 'Create Student'
      expect(page).to have_content "#{@group.full_mlid}-1A"

      click_link 'Edit'
      fill_in 'student_first_name', with: 'Updated'
      find('#student_gender_m').click
      click_button 'Update Student'

      expect(page).to have_content 'Updated'
      expect(page).to have_content 'M'
    end
  end
end
