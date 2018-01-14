# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with Groups' do
  include_context 'login_with_global_admin'

  describe 'Group creation' do
    before :each do
      create :chapter, chapter_name: 'Chapter One'
    end

    it 'creates a new group', js: true do
      visit '/groups'
      click_link 'Add Group'
      fill_in 'Group name', with: 'Feature Test Group'
      select 'Chapter One', from: 'group_chapter_id'
      click_button 'Create'

      expect(page).to have_content 'Feature Test Group'
      expect(page).to have_content 'Group "Feature Test Group" created.'
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
      click_link 'edit-button'
      fill_in 'Group name', with: 'Edited Group'
      select 'New Chapter', from: 'group_chapter_id'
      click_button 'Update'

      expect(page).to have_content 'Group "Edited Group" updated.'
      expect(page).to have_content 'Edited Group'
      expect(page).to have_content 'New Chapter'
    end
  end

  describe 'Group deleting and undeleting' do
    before :each do
      @group = create :group, group_name: 'About to be Deleted'
      @students = create_list :student, 3, group: @group
    end

    it 'marks the group as deleted' do
      visit '/groups'
      click_link 'About to be Deleted'
      click_button 'delete-button'

      expect(page).to have_content 'Group "About to be Deleted" deleted.'
      expect(@group.reload.deleted_at).to be_within(1.second).of Time.zone.now

      click_button 'Undo'

      expect(page).to have_content 'Group "About to be Deleted" restored.'
      expect(@group.reload.deleted_at).to be_nil
    end
  end
end
