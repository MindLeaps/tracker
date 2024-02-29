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
      select 'Subject Org', from: 'subject_organization_id'

      click_button 'Add Skill'
      expect(page).not_to have_content 'Deleted Skill'
      select 'Feature Test Skill I', from: 'subject[assignments_attributes][0][skill_id]'

      click_button 'Create'

      expect(page).to have_content 'Subject "Classical Dance" added'
      expect(page).to have_current_path(subject_path(Subject.last))
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
      find('div.table-cell', text: 'Test Subject', match: :first).click

      expect(page).to have_current_path subject_path(subject)
      expect(page).to have_content 'Test Subject'
      expect(page).to have_content skill_names[0]
      expect(page).to have_content skill_names[1]
      expect(page).to have_content skill_names[2]
    end

    it 'edits a subject', js: true do
      create :skill, skill_name: 'New Skill'
      create :skill, skill_name: 'Other Skill'
      subject = create :subject_with_skills, subject_name: 'Test Subject', number_of_skills: 2

      visit '/'
      click_link 'Subjects'
      find('div.table-cell', text: 'Test Subject', match: :first).click
      click_link 'Edit Subject'

      expect(page).to have_current_path edit_subject_path(subject)
      fill_in 'Subject name', with: 'Edited Name'
      click_button 'Add Skill'
      all(:select, 'subject_assignments_attributes_2_skill_id').last.find(:option, 'New Skill').select_option
      click_button 'Add Skill'
      all(:select, 'subject_assignments_attributes_3_skill_id').last.find(:option, 'Other Skill').select_option
      click_button 'Update Subject'

      expect(page).to have_current_path subject_path(subject)
      expect(page).to have_content 'Subject updated'
      expect(page).to have_content 'New Skill'
      expect(page).to have_content 'Other Skill'
      expect(subject.reload.skills.size).to eq 4
      expect(subject.subject_name).to eq 'Edited Name'
    end
  end
end
