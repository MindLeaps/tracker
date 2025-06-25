# == Schema Information
#
# Table name: country_summaries
#
#  id                 :bigint           primary key
#  country_name       :string
#  organization_count :bigint
#
require 'rails_helper'

RSpec.describe CountrySummary, type: :model do
  describe 'no countires present' do
    it 'returns no results' do
      expect(CountrySummary.all).to be_empty
    end
  end

  describe 'finding by id' do
    it 'finds the country summary by country id' do
      country = create :country
      expect(CountrySummary.find(country.id).country_name).to eq country.country_name
    end
  end

  describe 'calculations' do
    it 'should count organizations with the same country' do
      country = create :country
      create_list :organization, 3, country: country

      expect(CountrySummary.find(country.id).organization_count).to eq 3
    end
  end
end
