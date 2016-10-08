require 'rails_helper'

RSpec.describe 'User interacts with skills', js: true do
  context 'As a global administrator' do
    include_context 'login_with_admin'

    it 'list all skills' do
      create :skill, skill_name: 'Skill Feature Skill I'
      create :skill, skill_name: 'Skill Feature Skill II'

      visit '/'
      click_link 'Skills'

      expect(page).to have_css '.skill-row', count: 2
      expect(page).to have_content 'Skill Feature Skill I'
      expect(page).to have_content 'Skill Feature Skill II'
    end

    it 'creates a skill' do
      create :organization, organization_name: 'Skill Feature Organization'

      visit '/'
      click_link 'Skills'
      click_link 'New Skill'

      fill_in 'Skill name', with: 'Feature Test Skill'
      fill_in 'Skill description', with: 'This skill is usefull only for testing.'
      select 'Skill Feature Organization', from: 'skill_organization_id'

      click_link 'Add Grade Descriptor'
      fill_in 'Mark', with: '1'
      fill_in 'Grade description', with: 'This is a test grade'

      click_button 'Create'

      expect(page).to have_content 'Skill "Feature Test Skill" successfully created.'
      expect(page).to have_content 'Feature Test Skill'
    end

    it 'show a skill' do
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
      expect(page).to have_content 'Grade Descriptors'
      expect(page).to have_content '1 - Show Skill Feature Test Grade One'
      expect(page).to have_content '2 - Show Skill Feature Test Grade Two'
    end
  end
end
