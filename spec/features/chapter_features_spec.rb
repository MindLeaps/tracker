# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with Chapters' do
  include_context 'login_with_global_admin'

  describe 'Chapter Index' do
    chapters = []
    before :each do
      chapters = create_list :chapter, 3
      group1 = create :group, chapter: chapters[0]
      create_list :student, 3, group: group1
      create_list :student, 2, deleted_at: Time.zone.now, group: group1
      group2 = create :group, chapter: chapters[0]
      create_list :student, 2, group: group2

      group3 = create :group, chapter: chapters[1]
      create_list :student, 2, group: group3
      create_list :student, 2, group: group3, deleted_at: Time.zone.now
    end

    it 'Displays chapters with number of undeleted students' do
      visit '/chapters'
      expect(page).to have_content chapters[0].chapter_name
      expect(page).to have_content chapters[1].chapter_name
      expect(page).to have_content chapters[2].chapter_name

      expect(page.all('.resource-row td:last-child').map(&:text)).to include '5', '2', '0'
    end
  end

  describe 'Chapter creation' do
    before :each do
      @org = create :organization, organization_name: 'New Org'
    end

    it 'creates a new Chapter', js: true do
      visit '/chapters'
      click_link 'Add Chapter'
      fill_in 'Chapter name', with: 'Chapter One'
      select 'New Org', from: 'chapter_organization_id'
      click_button 'Create'

      expect(page).to have_content 'Chapter One'
      expect(page).to have_content 'Chapter "Chapter One" created.'
    end
  end

  describe 'Chapter editing' do
    before :each do
      @org1 = create :organization, organization_name: 'Old Organization'
      @org2 = create :organization, organization_name: 'New Organization'

      @chapter = create :chapter, chapter_name: 'Test Chapter', organization: @org1
    end

    it 'changes the name and organization of chapter' do
      visit '/chapters'
      click_link 'Test Chapter'
      click_link 'edit-button'
      fill_in 'Chapter name', with: 'Edited Chapter'
      select 'New Organization', from: 'chapter_organization_id'
      click_button 'Update'

      expect(page).to have_content 'Chapter "Edited Chapter" updated.'
      expect(page).to have_content 'Edited Chapter'

      expect(@chapter.reload.organization.id).to be @org2.id
    end
  end
end
