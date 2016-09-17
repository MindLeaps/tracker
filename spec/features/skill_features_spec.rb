require 'rails_helper'

RSpec.describe 'User interacts with skills' do
  context 'As a global administrator' do
    include_context 'login_with_admin'

    it 'lists all skills' do
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

      fill_in 'Skill name', with: 'Feature Test Skill'
      select 'Skill Feature Organization', from: 'skill_organization_id'
      click_button 'Create'

      expect(page).to have_content 'Skill "Feature Test Skill" successfully created.'
      expect(page).to have_css '.skill-row', count: 1
    end
  end
end
