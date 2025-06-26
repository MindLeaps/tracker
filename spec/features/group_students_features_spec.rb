require 'rails_helper'

RSpec.describe 'User interacts with students in Group', js: true do
  include_context 'login_with_global_admin'

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

      fill_in 'student_mlid', with: '1A'
      fill_in 'student_last_name', with: 'Student'
      fill_in 'student_first_name', with: 'New'
      fill_in 'student_dob', with: '2024-01-01'
      find('#student_gender_nb').click
      click_button 'Create Student'

      expect(page).to have_content "#{@group.full_mlid}-1A"
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

  describe 'Student Importing' do
    before :each do
      @group = create :group, group_name: 'Group One'
    end

    it 'renders form when trying to import students' do
      visit "/groups/#{@group.id}"
      click_link 'Import Students CSV'

      within('#modal') do
        expect(page).to have_content 'Import Students'
        expect(page).to have_content 'Import'
        expect(page).to have_content 'Cancel'
      end
    end

    it 'renders error messages when trying to upload invalid file', skip: 'test fails with selenium headless' do
      visit "/groups/#{@group.id}"
      click_link 'Import Students CSV'

      within('#modal') do
        page.attach_file('import_file', 'spec/fixtures/files/invalid_import.csv', make_visible: true)
        click_button 'Import'

        expect(page).to have_content 'Please check your file for the following errors:'
        expect(page).to have_content 'Last name can\'t be blank'
        expect(page).to have_content 'Gender can\'t be blank'
      end
    end

    it 'imports students when file upload is successful', skip: 'test fails with selenium headless' do
      visit "/groups/#{@group.id}"
      click_link 'Import Students CSV'

      within('#modal') do
        page.attach_file('import_file', 'spec/fixtures/files/valid_import.csv', make_visible: true)
        click_button 'Import'
      end

      expect(page).to have_content 'Imported Students'
      expect(page).to have_content 'Students imported successfully'
      expect(page).to have_content 'Marko'
      expect(page).to have_content 'Rick'
      expect(@group.students.count).to be 2
    end
  end
end
