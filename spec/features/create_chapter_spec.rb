# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Create chapter' do
  include_context 'login_with_admin'

  it 'creates a new Chapter', js: true do
    visit '/chapters'
    fill_in 'Chapter name', with: 'New Chapter Name For Create Chapter Feature Test'
    click_button 'Create'

    expect(page).to have_content 'New Chapter Name For Create Chapter Feature Test'
  end
end
