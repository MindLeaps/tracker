# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with subjects', js: true do
  context 'As a global super administrator' do
    include_context 'login_with_super_admin'

    before :each do
      @org = create :organization
      @org2 = create :organization

      @other_user = create :teacher_in, organization: @org
      visit '/'
      click_link 'Users'
    end

    it 'changes user\'s role, in the organization, from teacher to administrator and add an admin role in other organization' do
      Bullet.enable = false
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
      Bullet.enable = true
    end
  end
end

def form_for(organization)
  find("#user-roles-for\\[#{organization.id}\\]")
end
