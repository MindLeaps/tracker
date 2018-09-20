# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with Students' do
  include_context 'login_with_global_admin'

  describe 'List Students' do
    before :each do
      @org = create :organization
      create :student, first_name: 'Umberto', last_name: 'Eco', mlid: 'ECO-123', organization: @org
      create :student, first_name: 'Amberto', last_name: 'Oce', mlid: 'OCE-123', organization: @org
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

  describe 'Show student' do
    before :each do
      @org = create :organization
      create :student, first_name: 'Umberto', last_name: 'Eco', mlid: 'ECO-123', organization: @org
    end

    it 'shows Umbeto Eco\'s details' do
      visit '/students'
      click_link 'Umberto'
      expect(page).to have_content 'Umberto'
      expect(page).to have_content 'Eco'
      expect(page).to have_content 'ECO-123'
    end
  end

  describe 'Create student' do
    before :each do
      create :organization
    end

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

  describe 'Edit student' do
    before :each do
      create :organization
      create :student, first_name: 'Editovsky', last_name: 'Editus'
    end

    it 'renames Editovsky', js: true do
      visit '/students'

      click_link 'Editovsky'
      click_link 'edit-button'
      fill_in 'First name', with: 'Editoredsky'
      click_button 'Update'

      expect(page).to have_content 'Editoredsky'
      expect(page).to have_content 'Editus'
    end
  end

  describe 'Delete student' do
    before :each do
      @org = create :organization

      @student = create :student, first_name: 'Deleto', last_name: 'Mea', organization: @org
    end

    it 'deletes student Deleto Mea', js: true do
      visit '/students'
      click_link 'Mea'
      click_button 'delete-button'

      expect(page).to have_content 'Student "Mea, Deleto" deleted.'
    end
  end
end
