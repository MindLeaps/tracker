require 'rails_helper'

RSpec.describe 'User interacts with skills', js: true do
  context 'As a global administrator' do
    include_context 'login_with_global_admin'

    describe 'listing, searching, and filtering skills' do
      before :each do
        create :skill, skill_name: 'Memorization', created_at: Time.zone.now
        create :skill, skill_name: 'Discipline', created_at: 1.day.ago
        create :skill, skill_name: 'Language', created_at: 10.days.ago

        visit '/skills'
      end

      it 'lists all skills' do
        expect(page).to have_css 'div.table-row-wrapper', count: 3
        rows = page.all('div.table-row-wrapper')
        expect(rows[0]).to have_content 'Memorization'
        expect(rows[1]).to have_content 'Discipline'
        expect(rows[2]).to have_content 'Language'
      end

      it 'searched for a specific skill' do
        find('#search-field').send_keys('lan', :enter)
        expect(page).to have_css 'div.table-row-wrapper', count: 1
        rows = page.all('div.table-row-wrapper')
        expect(rows[0]).to have_content 'Language'
      end
    end

    it 'creates a skill' do
      create :organization, organization_name: 'Skill Feature Organization'

      visit '/'
      click_link 'Skills'
      click_link 'Add Skill'

      fill_in 'Skill name', with: 'Feature Test Skill'
      fill_in 'Skill description', with: 'This skill is useful only for testing.'
      select 'Skill Feature Organization', from: 'skill_organization_id'

      click_button 'Add Grade'
      fill_in 'Mark', with: '1'
      fill_in 'Grade description', with: 'This is a test grade'

      click_button 'Create'

      expect(page).to have_content 'Skill Added'
      expect(page).to have_content 'Feature Test Skill'
    end

    it 'shows a skill' do
      org = create :organization, organization_name: 'Skill Feature Show Organization'
      group = create :group, chapter: create(:chapter, organization: org), group_name: 'Skill Feature Group'
      desc1 = create :grade_descriptor, mark: 1, grade_description: 'Show Skill Feature Test Grade One'
      desc2 = create :grade_descriptor, mark: 2, grade_description: 'Show Skill Feature Test Grade Two'
      skill = create :skill_in_subject, skill_name: 'Some Skill', skill_description: 'This is a skill for feature testing',
                                        organization: org, grade_descriptors: [desc1, desc2]
      create :graded_student, organization: org, groups: [group], grades: { 'Some Skill' => [1, 2, 1] }, subject: skill.subjects.first
      additional_subject = create :subject, organization: org
      skill.subjects << additional_subject
      skill.save!

      visit '/'
      click_link 'Skills'

      find('div.table-cell', text: 'Some Skill', match: :first).click

      expect(page).to have_content 'Some Skill'
      expect(page).to have_content 'This is a skill for feature testing'
      expect(page).to have_content 'Skill Feature Show Organization'
      expect(page).to have_content 'Grades'
      expect(page).to have_content 'Show Skill Feature Test Grade One'
      expect(page).to have_content 'Show Skill Feature Test Grade Two'
      expect(page).to have_content 'Subjects with this skill'
      expect(page).to have_content skill.subjects[0].subject_name
      expect(page).to have_content skill.subjects[1].subject_name
      expect(page).to have_content "Average Mark for Skill: #{(1 + 2 + 1) / 3}"
      expect(page).to have_content 'Mark percentages'
    end

    describe 'Skill Deletion' do
      before :each do
        @skill = create :skill, skill_name: 'Skill To Be Deleted'
        visit '/skills'
      end

      it 'deletes an existing skill, lists it in the skill table, and then undeletes it' do
        find('div.table-cell', text: 'Skill To Be Deleted', match: :first).click

        click_button 'Delete Skill'

        expect(page).to have_content 'Skill "Skill To Be Deleted" deleted.'
        expect(@skill.reload.deleted_at).not_to be_nil

        expect(page).not_to have_link('Skill To Be Deleted')

        click_button 'Undo'
        expect(page).to have_content 'Skill "Skill To Be Deleted" restored.'
        expect(@skill.reload.deleted_at).to be_nil
      end

      it 'restores an existing deleted skill' do
        skill = create :skill, skill_name: 'Undelete', deleted_at: Time.zone.now

        click_link_compat 'Show Deleted'
        find('div.table-cell', text: 'Undelete', match: :first).click
        click_button 'Restore Skill'
        expect(page).to have_content 'Skill "Undelete" restored.'
        expect(skill.reload.deleted_at).to be_nil
      end
    end
  end
end
