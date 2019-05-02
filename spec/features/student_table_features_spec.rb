# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User searches and navigates through students table', js: true do
  include_context 'login_with_global_admin'

  context 'without pagination' do
    before :each do
      create :student, first_name: 'Umborato', last_name: 'Aco', mlid: 'ACO-123'
      create :student, first_name: 'Umberto', last_name: 'Eco', mlid: 'ECO-123'
      create :student, first_name: 'Umbdeleto', last_name: 'Del', mlid: 'DEL-123', deleted_at: Time.zone.now
      create :student, first_name: 'Amberto', last_name: 'Oce', mlid: 'OCE-123'
    end

    it 'displays searched students, including deleted' do
      visit '/students'
      expect(page).to have_selector('.resource-row', count: 3)
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.resource-row', count: 4)
      find('#search-field').send_keys('Umb', :enter)
      expect(page).to have_selector('.resource-row', count: 3)
      rows = page.all('.resource-row')
      expect(rows[0]).to have_content 'Umborato'
      expect(rows[1]).to have_content 'Umberto'
      expect(rows[2]).to have_content 'Umbdeleto'
      expect(page).to have_field('search-field', with: 'Umb')
      click_link_compat 'Show Deleted'
      expect(page).to have_selector('.resource-row', count: 2)
      rows = page.all('.resource-row')
      expect(rows[0]).to have_content 'Umborato'
      expect(rows[1]).to have_content 'Umberto'
    end
  end

  context 'with pagination' do
    before :each do
      create_list :student, 50
    end

    it 'navigates to the 2nd page and performs the search there' do
      create :student, first_name: 'test_prefix_Umborato', last_name: 'Aco', mlid: 'ACO-123'
      create :student, first_name: 'test_prefix_Umberto', last_name: 'Eco', mlid: 'ECO-123'
      create :student, first_name: 'test_prefix_Umbdeleto', last_name: 'Del', mlid: 'DEL-123', deleted_at: Time.zone.now
      create :student, first_name: 'test_prefix_Amberto', last_name: 'Oce', mlid: 'OCE-123'

      visit '/students'
      expect(page).to have_selector('.resource-row', count: 50)
      find('#next-page-button').click
      expect(page).to have_selector('.resource-row', count: 3)
      click_link_compat('Show Deleted')
      expect(page).to have_selector('.resource-row', count: 4)
      find('#search-field').send_keys('test_prefix_Amb', :enter)
      expect(page).to have_selector('.resource-row', count: 1)
      find('#search-field').send_keys([:backspace] * 15, :enter)
      expect(page).to have_selector('.resource-row', count: 50)
      find('#next-page-button').click
      expect(page).to have_selector('.resource-row', count: 4)
    end

    it 'shows deleted, navigates to 2nd page where there are only deleted students and then hides deleted' do
      create :student, first_name: 'test_prefix_Umborato', last_name: 'Aco', mlid: 'ACO-123', deleted_at: Time.zone.now
      create :student, first_name: 'test_prefix_Umberto', last_name: 'Eco', mlid: 'ECO-123', deleted_at: Time.zone.now
      create :student, first_name: 'test_prefix_Umbdeleto', last_name: 'Del', mlid: 'DEL-123', deleted_at: Time.zone.now
      create :student, first_name: 'test_prefix_Amberto', last_name: 'Oce', mlid: 'OCE-123', deleted_at: Time.zone.now

      visit '/students'
      expect(page).to have_selector('.resource-row', count: 50)
      expect(page).to have_selector '#next-page-button[disabled]'
      click_link_compat('Show Deleted')
      find('#next-page-button:not([disabled])').click
      expect(page).to have_selector('.resource-row', count: 4)
      click_link_compat('Show Deleted')
      expect(page).to have_selector('.resource-row', count: 50)
    end
  end
end
