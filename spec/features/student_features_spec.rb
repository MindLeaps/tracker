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
      @organization = create :organization, organization_name: 'Council of Ricks'
    end

    it 'creates Rick', js: true do
      visit '/students'
      click_link 'Add Student'
      fill_in 'First name', with: 'Rick'
      fill_in 'Last name', with: 'Sanchez'
      fill_in 'Date of Birth', with: '1943-01-15'
      select('Antarctica', from: 'Country of nationality')
      select('Council of Ricks', from: 'student_organization_id')

      click_button 'Create'

      expect(page).to have_content 'Student "Sanchez, Rick" added'
      expect(page).to have_link 'Create another'

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

    context 'enrollments' do
      it 'adds groups for Guts', js: true do
        first_group = create :group, group_name: 'First Group'
        second_group = create :group, group_name: 'Second Group', chapter: first_group.chapter
        test_student = create :student, first_name: 'Guts', organization: first_group.chapter.organization

        visit '/students'
        find('div.table-cell', text: 'Guts', match: :first).click
        click_link 'Edit Student'
        add_and_select_group(first_group.chapter_group_name_with_full_mlid, 0)
        click_button 'Update'

        test_student.reload
        expect(test_student.enrollments.size).to eq 1
        expect(test_student.enrollments.first.group_id).to eq(first_group.id)
        expect(page).to have_content 'First Group'

        click_link 'Edit Student'
        add_and_select_group(second_group.chapter_group_name_with_full_mlid, 1)
        click_button 'Update'

        test_student.reload
        expect(test_student.enrollments.size).to eq 2
        expect(test_student.enrollments.map(&:group_id)).to include first_group.id, second_group.id
        expect(page).to have_content 'Second Group'
      end

      it 'edits and deletes groups for Guts', js: true do
        first_group = create :group, group_name: 'First Group'
        second_group = create :group, group_name: 'Second Group', chapter: first_group.chapter
        test_student = create :enrolled_student, first_name: 'Guts', organization: first_group.chapter.organization, groups: [first_group, second_group]

        visit '/students'
        find('div.table-cell', text: 'Guts', match: :first).click
        click_link 'Edit Student'

        find('button', text: 'Delete Enrollment', match: :first).click
        fill_in 'student_enrollments_attributes_1_inactive_since', with: Time.zone.now.strftime('%Y-%m-%d')
        click_button 'Update'

        test_student.reload
        expect(test_student.enrollments.size).to eq 1
        expect(test_student.enrollments.first.group_id).to eq(second_group.id)
        expect(test_student.enrollments.first.inactive_since).to eq Time.zone.now.to_date
        expect(page).not_to have_content 'First Group'
        expect(page).to have_content 'Second Group'
      end
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

def add_and_select_group(chapter_group_name, group_index)
  click_button 'Add Group'
  select chapter_group_name, from: "student_enrollments_attributes_#{group_index}_group_id"
  fill_in "student_enrollments_attributes_#{group_index}_active_since", with: Time.zone.today.strftime('%Y-%m-%d')
end
