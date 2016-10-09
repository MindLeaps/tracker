# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'User interacts with subjects', js: true do
  context 'As a global administrator' do
    include_context 'login_with_admin'

    before :each do
      @organization = create :organization, organization_name: 'Subject Org'
    end

    it 'creates a subject' do
      create :skill, skill_name: 'Feature Test Skill I'

      visit '/'
      click_link 'Subjects'

      fill_in 'Subject name', with: 'Classical Dance'
      select 'Subject Org', from: 'Organization'
      click_link 'Add Skill'
      select 'Feature Test Skill I', from: 'Skill'
      click_button 'Create'

      expect(page).to have_content 'Subject "Classical Dance" successfully created'
      expect(page).to have_css '.subject-row', count: 1
    end

    it 'lists all existing subjects' do
      create :subject, subject_name: 'Subject For Index Test I'
      create :subject, subject_name: 'Subject For Index Test II'

      visit '/'
      click_link 'Subjects'

      expect(page).to have_content 'Subject For Index Test I'
      expect(page).to have_content 'Subject For Index Test II'
    end
  end
end
