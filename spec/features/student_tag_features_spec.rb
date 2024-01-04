# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User interacts with Student Tags' do
  include_context 'login_with_global_admin'

  describe 'Create Tag' do
    before :each do
      @org = create :organization
      @tags = create_list :tag, 3, organization: @org
    end

    it 'navigates to tags, creates a new tag and assigns it to the student', js: true do
      create :student, first_name: 'Taggy', last_name: 'Studenty', gender: 'F'

      visit '/students'
      click_link 'Student Tags'
      click_link 'Add Tag'
      fill_in 'Tag name', with: 'My Test Tag'
      select(@org.organization_name, from: 'Organization')
      find('label', text: 'Shared').click
      click_button 'Create'

      expect(page).to have_content 'Tag "My Test Tag" added'
      expect(page).to have_content 'Tag Name: My Test Tag'

      expect(page).to have_content 'My Test Tag'
      expect(page).to have_content @tags[0].tag_name
      expect(page).to have_content @tags[1].tag_name
      expect(page).to have_content @tags[2].tag_name

      click_link 'My Test Tag'
      find(:css, '#edit-button').click

      fill_in 'Tag name', with: 'My Edited Tag'
      click_button 'Update'

      expect(page).to have_content 'My Edited Tag'

      find(:css, '#back-button').click
      expect(page).to have_content 'My Edited Tag'

      visit '/students'
      click_link 'Taggy'
      click_link 'edit-button'
      fill_in 'tags_autocomplete', with: 'My Edited T'
      find('#awesomplete_list_1_item_0').click
      click_button 'Update'

      visit '/students'
      click_link 'Student Tags'
      click_link 'My Edited Tag'
    end
  end
end
