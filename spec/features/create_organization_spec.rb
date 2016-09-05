require 'rails_helper'

RSpec.describe 'Create organization' do
  include_context 'login'

  it 'creates MindLeapsTest orgnization', js: true do
    visit '/organizations'
    fill_in 'Organization name', with: 'MindLeapsTest'
    click_button 'Create'

    expect(page).to have_content 'MindLeapsTest'
  end
end
