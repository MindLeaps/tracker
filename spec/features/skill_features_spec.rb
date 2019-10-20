# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with skills', js: true do
  context 'As a global administrator' do
    include_context 'login_with_global_admin'

    describe 'listing, searching, and filtering skills' do
      before :each do
        create :skill, skill_name: 'Memorization'
        create :skill, skill_name: 'Discipline'
        create :skill, skill_name: 'Language'

        visit '/skills'
      end

      it 'lists all skills' do
        expect(page).to have_css '.resource-row', count: 3
        rows = page.all('.resource-row')
        expect(rows[0]).to have_content 'Memorization'
        expect(rows[1]).to have_content 'Discipline'
        expect(rows[2]).to have_content 'Language'
      end

      it 'searched for a specific skill' do
        find('#search-field').send_keys('lan', :enter)
        expect(page).to have_css '.resource-row', count: 1
        rows = page.all('.resource-row')
        expect(rows[0]).to have_content 'Language'
      end
    end

    it 'creates a skill' do
      create :organization, organization_name: 'Skill Feature Organization'

      visit '/'
      click_link 'Skills'
      click_link 'Add Skill'

      fill_in 'Skill name', with: 'Feature Test Skill'
      fill_in 'Skill description', with: 'This skill is usefull only for testing.'
      select 'Skill Feature Organization', from: 'skill_organization_id'

      click_link 'Add Grade Descriptor'
      fill_in 'Mark', with: '1'
      fill_in 'Grade description', with: 'This is a test grade'

      click_button 'Create'

      expect(page).to have_content 'Skill "Feature Test Skill" created.'
      expect(page).to have_content 'Feature Test Skill'
    end

    it 'shows a skill' do
      org = create :organization, organization_name: 'Skill Feature Show Organization'
      desc1 = create :grade_descriptor, mark: 1, grade_description: 'Show Skill Feature Test Grade One'
      desc2 = create :grade_descriptor, mark: 2, grade_description: 'Show Skill Feature Test Grade Two'
      create :skill, skill_name: 'Skill Feature Show Skill', skill_description: 'This is a skill for feature testing',
                     organization: org, grade_descriptors: [desc1, desc2]

      visit '/'
      click_link 'Skills'

      click_link 'Skill Feature Show Skill'

      expect(page).to have_content 'Skill Feature Show Skill'
      expect(page).to have_content 'This is a skill for feature testing'
      expect(page).to have_content 'Skill Feature Show Organization'
      expect(page).to have_content 'Grades'
      expect(page).to have_content 'Show Skill Feature Test Grade One'
      expect(page).to have_content 'Show Skill Feature Test Grade Two'
    end

    describe 'Skill Deletion' do
      before :each do
        @skill = create :skill, skill_name: 'Skill To Be Deleted'
        visit '/skills'
      end

      it 'deletes an existing skill, lists it in the skill table, and then undeletes it' do
        click_link 'Skill To Be Deleted'

        click_button 'delete-dialog-button'
        click_button 'confirm-delete-button'

        expect(page).to have_content 'Skill "Skill To Be Deleted" deleted.'
        expect(@skill.reload.deleted_at).not_to be_nil

        expect(page).not_to have_link('Skill To Be Deleted')
        click_link_compat 'Show Deleted'
        click_link 'Skill To Be Deleted'

        click_button 'undelete-button'
        expect(page).to have_content 'Skill "Skill To Be Deleted" restored.'
        expect(@skill.reload.deleted_at).to be_nil
      end
    end
  end
end
