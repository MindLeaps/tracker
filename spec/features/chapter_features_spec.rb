require 'rails_helper'

RSpec.describe 'User interacts with Chapters' do
  include_context 'login_with_global_admin'

  describe 'Viewing chapters' do
    chapters = []
    before :each do
      chapters = create_list :chapter, 4
      group1 = create :group, chapter: chapters[0], group_name: 'Testing Group 1'
      create_list :student, 3, group: group1
      create_list :student, 2, deleted_at: Time.zone.now, group: group1
      group2 = create :group, chapter: chapters[0], group_name: 'Group Testing 2'
      create_list :student, 2, group: group2

      group3 = create :group, chapter: chapters[1]
      create_list :student, 2, group: group3
      create_list :student, 2, group: group3, deleted_at: Time.zone.now

      create :group, chapter: chapters[2]
    end

    it 'Displays a list of chapters with number of non-deleted students' do
      visit '/chapters'
      expect(page).to have_content chapters[0].chapter_name
      expect(page).to have_content chapters[1].chapter_name
      expect(page).to have_content chapters[2].chapter_name

      expect(page.all('.chapter-row > a:first-child > div:nth-child(6)').map(&:text).sort).to eq %w[5 2 0 0].sort
    end

    it 'displays the details of a single chapter' do
      visit '/chapters'
      click_link chapters[0].chapter_name

      expect(page).to have_content 'Testing Group 1'
      expect(page).to have_content 'Group Testing 2'
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
      fill_in 'chapter_mlid', with: 'M0'
      select 'New Org', from: 'chapter_organization_id'
      click_button 'Create'

      expect(page).to have_content 'Chapter One'
      expect(page).to have_content 'Chapter "Chapter One" added'
    end

    it 'renders error flash when submitted form is incomplete' do
      visit '/chapters'
      click_link 'Add Chapter'
      fill_in 'Chapter name', with: 'Chapter One'
      click_button 'Create'
      expect(page).to have_content 'Chapter Invalid'
      expect(page).to have_content 'Please fix the errors in the form'
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
      click_link 'Edit Chapter'
      fill_in 'Chapter name', with: ''
      click_button 'Update'
      expect(page).to have_content 'Chapter Invalid'
      fill_in 'Chapter name', with: 'Edited Chapter'
      select 'New Organization', from: 'chapter_organization_id'
      click_button 'Update'

      expect(page).to have_content 'Chapter "Edited Chapter" updated.'
      expect(page).to have_content 'Edited Chapter'

      expect(@chapter.reload.organization.id).to be @org2.id
    end
  end
end
