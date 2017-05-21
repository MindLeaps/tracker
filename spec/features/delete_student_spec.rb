# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Create student' do
  before :each do
    @org = create :organization

    @student = create :student, first_name: 'Deleto', last_name: 'Mea', organization: @org
  end
  include_context 'login_with_admin'

  it 'deletes student Deleto Mea', js: true do
    visit '/students'
    click_link 'Mea'
    click_button 'Delete'

    expect(page).to have_content 'Student "Mea, Deleto" deleted.'
  end
end
