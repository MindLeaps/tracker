# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with Students' do
  include_context 'login_with_global_admin'

  describe 'List Students' do
    before :each do
      create :student, first_name: 'Umberto', last_name: 'Eco', mlid: 'ECO-123'
      create :student, first_name: 'Amberto', last_name: 'Oce', mlid: 'OCE-123'
    end

    it 'sorts students by first name alphabetically' do
      visit '/students'
      click_link 'First Name'
      rows = page.all('.resource-row')
      expect(rows[0]).to have_content 'Amberto'
      expect(rows[1]).to have_content 'Umberto'
      click_link 'First Name'
      rows = page.all('.resource-row')
      expect(rows[0]).to have_content 'Umberto'
      expect(rows[1]).to have_content 'Amberto'
    end
  end

  describe 'Clicking on a student shows their performance and details' do
    before :each do
      create :graded_student, first_name: 'Umberto', last_name: 'Eco', mlid: 'ECO-123', grades: {
        'Memorization' => [1, 5, 7],
        'Grit' => [2, 3, 3]
      }
    end

    it 'shows Umberto Eco\'s performance and details' do
      visit '/students'
      click_link 'Umberto'
      expect(page).to have_content 'Umberto'
      expect(page).to have_content 'Eco'
      expect(page).to have_content 'Performance'
      expect(page).to have_content '1.5'
      expect(page).to have_content '4.0'
      expect(page).to have_content '5.0'

      click_link 'Details'
      expect(page).to have_content 'Date of Birth'
      expect(page).to have_content 'MLID'
      expect(page).to have_content 'Gender'

      click_link 'Performance'
      expect(page).to have_content '1.5'
      expect(page).to have_content '4.0'
      expect(page).to have_content '5.0'
    end
  end

  describe 'Create student' do
    before :each do
      @group = create :group
    end

    it 'creates Rick', js: true do
      visit '/students'
      click_link 'Add Student'
      fill_in 'MLID', with: '1A'
      fill_in 'First name', with: 'Rick'
      fill_in 'Last name', with: 'Sanchez'
      select('Antarctica', from: 'Country of nationality')
      select(@group.group_chapter_name, from: 'Group')
      click_button 'Create'

      expect(page).to have_content 'Student "Sanchez, Rick" created.'
      expect(page).to have_link 'Create another', href: new_student_path(group_id: @group.id)

      created_student = Student.find_by! first_name: 'Rick', last_name: 'Sanchez'

      expect(created_student.gender).to eq('M')
      expect(created_student.country_of_nationality).to eq('AQ')
    end
  end

  describe 'Edit student' do
    it 'renames Editovska', js: true do
      test_student = create :student, first_name: 'Editovska', last_name: 'Editus', gender: 'F'
      create :tag, tag_name: 'Soldier'

      visit '/students'

      click_link 'Editovska'
      click_link 'edit-button'
      fill_in 'First name', with: 'Editoredska'
      fill_in 'tags_autocomplete', with: 'Sol'
      find('#awesomplete_list_1_item_0').click
      click_button 'Update'

      expect(page).to have_content 'Editoredska'
      expect(page).to have_content 'Editus'
      expect(page).to have_content 'Soldier'
      test_student.reload
      expect(test_student.first_name).to eq('Editoredska')
      expect(test_student.last_name).to eq('Editus')
      expect(test_student.gender).to eq('F')
      expect(test_student.tags.map(&:tag_name)).to include('Soldier')
    end
  end

  describe 'Delete student' do
    before :each do
      create :student, first_name: 'Deleto', last_name: 'Mea'
    end

    it 'deletes student Deleto Mea', js: true do
      visit '/students'
      click_link 'Mea'
      click_button 'delete-button'

      expect(page).to have_content 'Student "Mea, Deleto" deleted.'
    end
  end
end
