# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with subjects', js: true do
  context 'As a global administrator' do
    include_context 'login_with_global_admin'

    it 'creates a subject' do
      create :organization, organization_name: 'Subject Org'
      create :skill, skill_name: 'Feature Test Skill I'
      create :skill, skill_name: 'Deleted Skill', deleted_at: Time.zone.now

      visit '/'
      click_link 'Subjects'
      click_link 'Add Subject'

      fill_in 'Subject name', with: 'Classical Dance'
      select 'Subject Org', from: 'Organization'

      click_link 'Add Skill'
      expect(page).not_to have_content 'Deleted Skill'
      select 'Feature Test Skill I', from: 'Skill'

      click_button 'Create'

      expect(page).to have_content 'Subject "Classical Dance" created'
      expect(page).to have_css '.resource-row', count: 1
    end

    it 'lists all existing subjects' do
      create :subject, subject_name: 'Subject For Index Test I'
      create :subject, subject_name: 'Subject For Index Test II'

      visit '/'
      click_link 'Subjects'

      expect(page).to have_content 'Subject For Index Test I'
      expect(page).to have_content 'Subject For Index Test II'
    end

    it 'shows subject details' do
      subject = create :subject_with_skills, subject_name: 'Test Subject', number_of_skills: 3
      skill_names = subject.skills.map(&:skill_name)

      visit '/'
      click_link 'Subjects'
      click_link 'Test Subject'

      expect(page).to have_current_path subject_path(subject)
      expect(page).to have_content 'Test Subject'
      expect(page).to have_content skill_names[0]
      expect(page).to have_content skill_names[1]
      expect(page).to have_content skill_names[2]

      click_link 'back-button'

      expect(page).to have_current_path subjects_path
    end

    it 'edits a subject' do
      create :skill, skill_name: 'New Skill'
      subject = create :subject_with_skills, subject_name: 'Test Subject', number_of_skills: 2

      visit '/'
      click_link 'Subjects'
      click_link 'Test Subject'
      click_link 'edit-button'

      expect(page).to have_current_path edit_subject_path(subject)
      fill_in 'Subject name', with: 'Edited Name'
      click_link 'Add Skill'
      all(:select, 'Skill').last.find(:option, 'New Skill').select_option
      click_button 'Update'

      expect(page).to have_current_path subject_path(subject)
      expect(page).to have_content 'Subject updated.'
      expect(page).to have_content 'New Skill'
    end
  end
end
