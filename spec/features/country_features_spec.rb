require 'rails_helper'

RSpec.describe 'Interaction with Countries' do
  include_context 'login_with_super_admin'

  describe 'country creation' do
    it 'creates a new country', js: true do
      visit '/countries'
      click_link 'Add Country'
      fill_in 'Country name', with: 'New Country For Feature Testing'
      click_button 'Create'

      expect(page).to have_content 'Country Added'
      expect(page).to have_content 'New Country For Feature Testing'
    end
  end

  describe 'viewing a single country' do
    before :each do
      @country = create :country
      @organizations = create_list :organization, 3, country: @country

      visit '/countries'
      click_link @country.country_name
    end

    it 'displays the country\'s organizations' do
      @organizations.each { |o| expect(page).to have_content o.organization_name }
    end
  end

  describe 'editing a country' do
    before :each do
      @country = create :country, country_name: 'Original Country Name'

      visit '/countries'
      click_link @country.country_name
    end

    it 'updates the country\'s name' do
      expect(page).to have_content 'Edit Country'

      click_link 'Edit Country'
      fill_in 'Country name', with: 'New Country Name'
      click_button 'Update Country'

      expect(page).to have_content 'New Country Name'
      expect(@country.reload.country_name).to eq 'New Country Name'
    end
  end

  describe 'deleting a country' do
    before :each do
      @country = create :country, country_name: 'Original Country Name'

      visit '/countries'
      click_link @country.country_name
    end

    it 'removes the country' do
      expect(page).to have_content 'Delete Country'

      click_button 'Delete Country'

      expect(page).to have_content 'Country deleted'
      expect(page).to have_content "Country \"#{@country.country_name}\" deleted."
      expect(Country.exists?(@country.id)).to be false
    end
  end

  describe 'searching and filtering countries', js: true do
    before :each do
      @first_country = create :country, country_name: 'First Country'
      @second_country = create :country, country_name: 'Second Country'
      @third_country = create :country, country_name: 'Third Country'
    end

    it 'searches different countries by name' do
      visit '/countries'

      expect(page).to have_selector('.country-row', count: 3)

      fill_in 'search-field', with: 'Country'

      expect(page).to have_selector('.country-row', count: 3)

      fill_in 'search-field', with: 'First'
      expect(page).to have_selector('.country-row', count: 1)
      expect(page).to have_content 'First'
      expect(page).not_to have_content 'Second'
      expect(page).not_to have_content 'Third'
    end
  end
end
