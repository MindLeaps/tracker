# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with other users', js: true do
  context 'As a global super administrator' do
    include_context 'login_with_super_admin'

    before :each do
      Bullet.enable = false
      @org = create :organization
      @org2 = create :organization

      @other_user = create :teacher_in, organization: @org
      @global_guest = create :global_guest
      visit '/'
      click_link 'Users'
    end

    describe 'Add User' do
      it 'creates a new user' do
        visit '/users'
        click_link 'Add User'
        fill_in 'Email', with: 'silly@example.com'
        click_button 'Add User'

        expect(page).to have_content 'silly@example.com'
        expect(User.last.email).to eq 'silly@example.com'
        expect(page).to have_content 'User with email silly@example.com added.'
      end
    end

    describe 'Edit User' do

      after :each do
        Bullet.enable = true
      end

      it 'changes user\'s role, in the organization, from teacher to administrator and add an admin role in other organization' do
        click_link user_name(@other_user)
        form_for(@org2).choose('Teacher')
        form_for(@org2).click_button 'Update User Role'

        form_for(@org).choose('Administrator')
        form_for(@org).click_button 'Update User Role'

        expect(form_for(@org).find_field('Administrator')).to be_checked
        expect(form_for(@org2).find_field('Teacher')).to be_checked

        expect(@other_user.has_role?(:admin, @org)).to be true
        expect(@other_user.has_role?(:teacher, @org2)).to be true
        expect(@other_user.has_role?(:teacher, @org)).to be false
      end

      it 'revokes the user\'s role in the organization' do
        click_link user_name(@other_user)

        expect(page).to have_content "#{@org.organization_name}: Teacher"
        click_button "Revoke Role in #{@org.organization_name}"
        expect(@other_user.has_role?(:teacher, @org)).to be false
        expect(page).not_to have_content "#{@org.organization_name}: Teacher"
      end

      it 'changes the user\'s global role from global guest to global admin, then removes global role' do
        Bullet.enable = false
        click_link user_name(@global_guest)
        expect(page).to have_content Role::GLOBAL_ROLES[:global_guest]
        global_form.choose('Global Administrator')
        global_form.click_button 'Update Global User Role'

        expect(page).to have_content Role::GLOBAL_ROLES[:global_admin]
        expect(global_form.find_field('Global Administrator')).to be_checked
        expect(@global_guest.has_role?(:global_admin)).to be true
        expect(@global_guest.has_role?(:global_guest)).to be false

        click_button 'Revoke Global User Role'
        expect(@global_guest.has_role?(:global_guest)).to be false
        expect(@global_guest.has_role?(:global_admin)).to be false
      end
    end
  end
end

def form_for(organization)
  find("#user-roles-for\\[#{organization.id}\\]")
end

def global_form
  find('#user-roles-global')
end
