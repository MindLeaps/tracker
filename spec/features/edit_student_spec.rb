require 'rails_helper'

RSpec.describe 'Edit student' do
  include_context 'login_with_admin'
  before :each do
    create :student, first_name: 'Editovsky', last_name: 'Editus'
  end

  it 'renames Editovsky', js: true do
    visit '/students'

    click_link 'Editovsky'
    click_link 'Edit'
    fill_in 'First name', with: 'Editoredsky'
    click_button 'Update'

    expect(page).to have_content 'Editoredsky'
    expect(page).to have_content 'Editus'
  end
end
