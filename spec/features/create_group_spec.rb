require 'rails_helper'

RSpec.describe 'Create group' do
  include_context 'login'

  it 'creates Group A', js: true do
    visit '/groups'
    fill_in 'Group name', with: 'Group A'
    click_button 'Create'

    expect(page).to have_content 'Group A'
  end
end
