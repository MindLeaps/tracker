# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with Groups' do
  include_context 'login_with_global_admin'

  describe 'Group Index' do
    groups = []
    before :each do
      groups = create_list :group, 3
      create_list :student, 3, group: groups[0]
      students_with_deleted = create_list :student, 3, group: groups[1]
      students_with_deleted[2].deleted_at = Time.zone.now
      students_with_deleted[2].save
    end

    it 'displays a list of groups with counts of undeleted students' do
      visit 'groups'
      expect(page).to have_content groups[0].group_name
      expect(page).to have_content groups[1].group_name
      expect(page).to have_content groups[2].group_name

      expect(page.all('.resource-row td:last-child').map(&:text).sort).to eq %w[3 2 0].sort
    end
  end

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
      expect(page).to have_link 'Create another', href: new_group_path
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
      @deleted_group = create :group, deleted_at: Time.zone.now, group_name: 'Already Deleted'
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

    it 'restores an already deleted group' do
      visit "/groups/#{@deleted_group.id}"
      click_button 'undelete-button'
      visit '/groups'
      expect(page).to have_content 'Already Deleted'
      expect(@deleted_group.reload.deleted_at).to be_nil
    end
  end

  describe 'Group searching and filtering', js: true do
    before :each do
      @group1 = create :group, group_name: 'Abisamol'
      @group2 = create :group, group_name: 'Abisouena'
      @group4 = create :group, group_name: 'Abilatava', deleted_at: Time.zone.now
      @group3 = create :group, group_name: 'Milatava'
    end

    it 'searches different groups' do
      visit '/groups'
      expect(page).to have_selector('.resource-row', count: 3)
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.resource-row', count: 4)
      find('#search-field').send_keys('Abi', :enter)
      expect(page).to have_selector('.resource-row', count: 3)
      expect(page).to have_content 'Abisamol'
      expect(page).to have_content 'Abisouena'
      expect(page).to have_content 'Abilatava'
      expect(page).to have_field('search-field', with: 'Abi')
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.resource-row', count: 2)
      expect(page).to have_content'Abisamol'
      expect(page).to have_content'Abisouena'
    end
  end
end
