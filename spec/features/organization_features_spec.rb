require 'rails_helper'

RSpec.describe 'Interaction with Organizations' do
  include_context 'login_with_super_admin'

  describe 'Organization creation' do
    it 'creates a new organization', js: true do
      visit '/organizations'
      click_link 'Add Organization'
      fill_in 'Organization name', with: 'New Organization For Organization Feature Test'
      click_button 'Create'

      expect(page).to have_content 'Organization Added'
      expect(page).to have_content 'New Organization For Organization Feature Test'
    end
  end

  describe 'Viewing single organization' do
    before :each do
      @organization = create :organization
      @existing_members = create_list(:teacher_in, 3, organization: @organization)
      @existing_members << create(:admin_of, organization: @organization)
      @chapters = create_list(:chapter, 3, organization: @organization)

      visit '/organizations'
      click_link @organization.organization_name
    end

    it 'displays the organization\'s members and chapters' do
      @existing_members.each { |m| expect(page).to have_content m.name }

      @chapters.each { |c| expect(page).to have_content c.chapter_name }
    end
  end

  describe 'Adding members to organization' do
    before :each do
      @new_member = create :user

      @organization = create :organization
      @existing_member = create :admin_of, organization: @organization
    end

    it 'adds a an existing user as a new administrator to the organization' do
      visit '/'

      click_link 'Organizations'
      click_link @organization.organization_name

      fill_in 'Email', with: @new_member.email
      select 'Administrator', from: 'Role'
      click_button 'Add User'

      expect(page).to have_content @new_member.name
      expect(@new_member.reload.has_role?(:admin, @organization)).to be true
    end
  end

  describe 'Organization deleting and undeleting' do
    before :each do
      @organization = create :organization, organization_name: 'About to be Deleted'
      @deleted_organization = create :organization, deleted_at: Time.zone.now, organization_name: 'Already Deleted'
      @chapters = create_list :chapter, 3, organization: @organization
    end

    it 'marks the organization as deleted' do
      visit '/organizations'
      click_link 'About to be Deleted'
      click_button 'Delete Organization'

      expect(page).to have_content 'Organization "About to be Deleted" deleted.'
      expect(@organization.reload.deleted_at).to be_within(1.second).of Time.zone.now

      click_button 'Undo'

      expect(page).to have_content 'Organization "About to be Deleted" restored.'
      expect(@organization.reload.deleted_at).to be_nil
    end

    it 'restores an already deleted organization' do
      visit "/organizations/#{@deleted_organization.id}"
      click_button 'Restore Deleted Organization'
      visit '/organizations'
      expect(page).to have_content 'Already Deleted'
      expect(@deleted_organization.reload.deleted_at).to be_nil
    end
  end

  describe 'Organization searching and filtering', js: true do
    before :each do
      @org1 = create :organization, organization_name: 'Abisamol', country: 'Test Country'
      @org2 = create :organization, organization_name: 'Abisouena', country: 'Test Country'
      @org3 = create :organization, organization_name: 'Abilatava', deleted_at: Time.zone.now
      @org4 = create :organization, organization_name: 'Milatava', country: 'Aruba'
    end

    it 'searches different organizations' do
      visit '/organizations'
      expect(page).to have_selector('.organization-row', count: 3)
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.organization-row', count: 4)
      find('#search-field').send_keys('Abi', :enter)
      expect(page).to have_selector('.organization-row', count: 3)
      expect(page).to have_content 'Abisamol'
      expect(page).to have_content 'Abisouena'
      expect(page).to have_content 'Abilatava'
      expect(page).to have_field('search-field', with: 'Abi')
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.organization-row', count: 2)
      expect(page).to have_content 'Abisamol'
      expect(page).to have_content 'Abisouena'
    end

    it 'searches organizations by country' do
      visit '/organizations'

      expect(page).to have_selector('.organization-row', count: 3)

      fill_in 'search-field', with: 'Test'

      expect(page).to have_selector('.organization-row', count: 2)
      expect(page).to have_content 'Test Country'

      fill_in 'search-field', with: 'Aruba'

      expect(page).to have_selector('.organization-row', count: 1)
      expect(page).to have_content 'Aruba'
    end
  end
end
