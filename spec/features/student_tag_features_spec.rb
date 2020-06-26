# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with Student Tags' do
  include_context 'login_with_global_admin'

  describe 'Create Tag' do
    before :each do
      @org = create :organization
      @tags = create_list :tag, 3, organization: @org
    end

    it 'navigates to tags and creates a new tag' do
      visit '/students'
      click_link 'Student Tags'
      click_link 'Add Tag'
      fill_in 'Tag name', with: 'My Test Tag'
      select(@org.organization_name, from: 'Organization')
      check 'Shared'
      click_button 'Create'

      expect(page).to have_content 'Tag "My Test Tag" created.'
      expect(page).to have_content 'Tag Name: My Test Tag'
      expect(page).to have_content 'Organization: ' + @org.organization_name

      find(:css, '#back-button').click

      expect(page).to have_content 'My Test Tag'
      expect(page).to have_content @tags[0].tag_name
      expect(page).to have_content @tags[1].tag_name
      expect(page).to have_content @tags[2].tag_name
    end
  end
end
