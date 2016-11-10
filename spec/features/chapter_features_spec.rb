# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'User interacts with Chapters' do
  include_context 'login_with_admin'

  describe 'Chapter creation' do
    it 'creates a new Chapter', js: true do
      visit '/chapters'
      fill_in 'Chapter name', with: 'Chapter One'
      click_button 'Create'

      expect(page).to have_content 'Chapter One'
      expect(page).to have_content 'Chapter "Chapter One" successfully created.'
    end
  end

  describe 'Chapter editing' do
    before :each do
      @org1 = create :organization, organization_name: 'Old Organization'
      @org2 = create :organization, organization_name: 'New Organization'

      @chapter = create :chapter, chapter_name: 'Test Chapter', organization: @org1
    end

    it 'changes the name and organization of chapter' do
      visit '/chapters'
      click_link 'Test Chapter'
      click_link 'Edit'
      fill_in 'Chapter name', with: 'Edited Chapter'
      select 'New Organization', from: 'chapter_organization_id'
      click_button 'Update'

      expect(page).to have_content 'Chapter "Edited Chapter" successfully updated.'
      expect(page).to have_content 'Edited Chapter'
      expect(page).to have_content 'New Organization'
    end
  end
end
