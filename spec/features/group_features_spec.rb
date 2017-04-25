# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'User interacts with Groups' do
  include_context 'login_with_admin'

  describe 'Group creation' do
    it 'creates a new group', js: true do
      visit '/groups'
      fill_in 'Group name', with: 'Feature Test Group'
      click_button 'Create'

      expect(page).to have_content 'Feature Test Group'
      expect(page).to have_content 'Group "Feature Test Group" successfully created.'
    end
  end

  describe 'Group editing' do
    before :each do
      @chapter1 = create :chapter, chapter_name: 'Old Chapter'
      @chapter2 = create :chapter, chapter_name: 'New Chapter', organization: @chapter1.organization
      @group = create :group, group_name: 'Test Group', chapter: @chapter1
      create_list :student, 3, group: @group
    end

    it 'edits the name and chapter of an existing group' do
      visit '/groups'
      click_link 'Test Group'
      click_link 'Edit'
      fill_in 'Group name', with: 'Edited Group'
      select 'New Chapter', from: 'group_chapter_id'
      click_button 'Update'

      expect(page).to have_content 'Group "Edited Group" successfully updated.'
      expect(page).to have_content 'Edited Group'
      expect(page).to have_content 'New Chapter'
    end
  end
end
