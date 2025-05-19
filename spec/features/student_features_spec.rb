require 'rails_helper'

RSpec.describe 'User interacts with Students' do
  include_context 'login_with_global_admin'

  describe 'List Students' do
    before :each do
      create :student, first_name: 'Umberto', last_name: 'Eco', mlid: 'ECO'
      create :student, first_name: 'Amberto', last_name: 'Oce', mlid: 'OCE'
    end

    it 'sorts students by first name alphabetically' do
      visit '/students'
      click_link 'First Name'
      rows = page.all('.student-row')
      expect(rows[0]).to have_content 'Amberto'
      expect(rows[1]).to have_content 'Umberto'
      click_link 'First Name'
      rows = page.all('.student-row')
      expect(rows[0]).to have_content 'Umberto'
      expect(rows[1]).to have_content 'Amberto'
    end
  end

  describe 'Create student' do
    before :each do
      @group = create :group
    end

    it 'creates Rick', js: true do
      visit '/students'
      click_link 'Add Student'
      fill_in 'First name', with: 'Rick'
      fill_in 'Last name', with: 'Sanchez'
      fill_in 'Date of Birth', with: '1943-01-15'
      select('Antarctica', from: 'Country of nationality')
      select(@group.chapter_group_name_with_full_mlid, from: 'student_group_id')
      fill_in 'student_mlid', with: '1A'
      click_button 'Create'

      expect(page).to have_content 'Student "Sanchez, Rick" added'
      expect(page).to have_link 'Create another', href: new_student_path(group_id: @group.id)

      created_student = Student.find_by! first_name: 'Rick', last_name: 'Sanchez'

      expect(created_student.gender).to eq('M')
      expect(created_student.country_of_nationality).to eq('AQ')
    end

    it 'renders error flash when submitted form is incomplete', js: true do
      visit '/students'
      click_link 'Add Student'
      fill_in 'First name', with: 'Rick'
      fill_in 'Last name', with: 'Sanchez'
      click_button 'Create'
      expect(page).to have_content 'Student Invalid'
      expect(page).to have_content 'Please fix the errors in the form'
    end
  end

  describe 'Edit student' do
    it 'renames Editovska', js: true do
      test_student = create :student, first_name: 'Editovska', last_name: 'Editus', gender: 'F'
      create :tag, tag_name: 'Soldier'

      visit '/students'

      find('div.table-cell', text: 'Editovska', match: :first).click
      click_link 'Edit Student'
      fill_in 'First name', with: ''
      click_button 'Update'
      expect(page).to have_content 'Student Invalid'
      fill_in 'First name', with: 'Editoredska'
      fill_in 'tag-autocomplete', with: 'Sol'
      find('.awesomplete ul li:first-child').click
      click_button 'Update'

      expect(page).to have_content 'Editoredska'
      expect(page).to have_content 'Editus'
      expect(page).to have_content 'Soldier'
      test_student.reload
      expect(test_student.first_name).to eq('Editoredska')
      expect(test_student.last_name).to eq('Editus')
      expect(test_student.gender).to eq('F')
      expect(test_student.tags.map(&:tag_name)).to include('Soldier')
      expect(page).to have_content 'Student "Editus, Editoredska" updated'
    end
  end

  describe 'Delete student' do
    it 'deletes student Deleto Mea', js: true do
      @student = create :student, first_name: 'Deleto', last_name: 'Mea'
      visit '/students'
      find('div.table-cell', text: 'Deleto', match: :first).click
      expect(@student.reload.deleted_at).to be nil
      click_button 'Delete Student'
      expect(@student.reload.deleted_at).to_not be nil

      expect(page).to have_content 'Student "Mea, Deleto" deleted.'
    end

    it 'restores deleted student', js: true do
      @student = create :student, first_name: 'Restoro', last_name: 'Mea', deleted_at: Time.zone.now
      visit '/students'
      click_link_compat('Show Deleted')
      find('div.table-cell', text: 'Restoro', match: :first).click
      expect(@student.reload.deleted_at).to_not be nil
      click_button 'Restore Deleted Student'
      expect(@student.reload.deleted_at).to be nil
      expect(page).to have_content 'Student "Mea, Restoro" restored'
    end
  end
end
