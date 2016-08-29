require 'rails_helper'

RSpec.describe 'Edit student' do
  include_context 'login'

  it 'creates Rick', js: true do
    visit '/students'

    click_link 'Pesut'
    click_link 'Edit'
    fill_in 'Last name', with: 'Sutpe'
    click_button 'Update'

    expect(page).to have_content 'Tomislav'
    expect(page).to have_content 'Sutpe'
  end
end
