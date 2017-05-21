# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create organization' do
  include_context 'login_with_super_admin'

  it 'creates a new organization', js: true do
    visit '/organizations'
    fill_in 'Organization name', with: 'New Organization For Organization Feture Test'
    click_button 'Create'

    expect(page).to have_content 'New Organization For Organization Feture Test'
  end
end
