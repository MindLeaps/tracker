# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Create group' do
  include_context 'login_with_admin'

  it 'creates a new group', js: true do
    visit '/groups'
    fill_in 'Group name', with: 'New Group Name For Create Group Feature Test'
    click_button 'Create'

    expect(page).to have_content 'New Group Name For Create Group Feature Test'
  end
end
