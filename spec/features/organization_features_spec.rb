# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Interaction with Organizations' do
  include_context 'login_with_super_admin'

  describe 'Organization creation' do
    it 'creates a new organization', js: true do
      visit '/organizations'
      click_link 'Add Organization'
      fill_in 'Organization Name', with: 'New Organization For Organization Feature Test'
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
end
