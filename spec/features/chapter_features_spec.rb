require 'rails_helper'

RSpec.describe 'User interacts with Chapters' do
  include_context 'login_with_global_admin'

  describe 'Viewing chapters' do
    chapters = []
    before :each do
      chapters = create_list :chapter, 4
      group1 = create :group, chapter: chapters[0], group_name: 'Testing Group 1'
      create_list :enrolled_student, 3, organization: group1.chapter.organization, groups: [group1]
      create_list :enrolled_student, 2, organization: group1.chapter.organization, groups: [group1], deleted_at: Time.zone.now
      group2 = create :group, chapter: chapters[0], group_name: 'Group Testing 2'
      create_list :enrolled_student, 2, organization: group2.chapter.organization, groups: [group2]

      group3 = create :group, chapter: chapters[1]
      create_list :enrolled_student, 2, organization: group3.chapter.organization, groups: [group3]
      create_list :enrolled_student, 2, organization: group3.chapter.organization, groups: [group3], deleted_at: Time.zone.now

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

  describe 'Chapter deleting and undeleting' do
    before :each do
      @chapter = create :chapter, chapter_name: 'About to be Deleted'
      @deleted_chapter = create :chapter, deleted_at: Time.zone.now, chapter_name: 'Already Deleted'
    end

    it 'marks the chapter as deleted' do
      visit '/chapters'
      click_link 'About to be Deleted'
      click_button 'Delete Chapter'

      expect(page).to have_content 'Chapter "About to be Deleted" deleted.'
      expect(@chapter.reload.deleted_at).to be_within(1.second).of Time.zone.now

      click_button 'Undo'

      expect(page).to have_content 'Chapter "About to be Deleted" restored.'
      expect(@chapter.reload.deleted_at).to be_nil
    end

    it 'restores an already deleted chapter' do
      visit "/chapters/#{@deleted_chapter.id}"
      click_button 'Restore Deleted Chapter'
      visit '/chapters'
      expect(page).to have_content 'Already Deleted'
      expect(@deleted_chapter.reload.deleted_at).to be_nil
    end
  end

  describe 'Chapter searching and filtering', js: true do
    before :each do
      @chapter1 = create :chapter, chapter_name: 'Abisamol'
      @chapter2 = create :chapter, chapter_name: 'Abisouena'
      @chapter3 = create :chapter, chapter_name: 'Abilatava', deleted_at: Time.zone.now
      @chapter4 = create :chapter, chapter_name: 'Milatava'
    end

    it 'searches different chapters' do
      visit '/chapters'
      expect(page).to have_selector('.chapter-row', count: 3)
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.chapter-row', count: 4)
      find('#search-field').send_keys('Abi', :enter)
      expect(page).to have_selector('.chapter-row', count: 3)
      expect(page).to have_content 'Abisamol'
      expect(page).to have_content 'Abisouena'
      expect(page).to have_content 'Abilatava'
      expect(page).to have_field('search-field', with: 'Abi')
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.chapter-row', count: 2)
      expect(page).to have_content 'Abisamol'
      expect(page).to have_content 'Abisouena'
    end
  end
end
