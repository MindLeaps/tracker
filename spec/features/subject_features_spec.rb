require 'rails_helper'

RSpec.describe 'User interacts with subjects' do
  context 'As a global administrator' do
    include_context 'login_with_admin'

    before :all do
      @organization = create :organization, organization_name: 'Subject Org'
    end

    it 'creates a subject' do
      visit '/'
      click_link 'Subjects'

      fill_in 'Subject name', with: 'Classical Dance'
      select 'Subject Org', from: 'subject_organization_id'
      click_button 'Create'

      expect(page).to have_content 'Subject "Classical Dance" successfully created'
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
