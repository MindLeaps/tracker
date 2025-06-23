# == Schema Information
#
# Table name: countries
#
#  id           :bigint           not null, primary key
#  country_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
require 'rails_helper'

RSpec.describe Country, type: :model do
  let(:existing_country) { create :country, country_name: 'Already Existing Country' }

  it { should have_one :organization }

  describe 'is valid' do
    it 'with a valid, unique name' do
      country = Country.new country_name: 'Totally valid country'

      expect(country).to be_valid
      expect(country.country_name).to eql 'Totally valid country'
    end
  end

  describe 'is not valid' do
    it 'without a country name' do
      country = Country.new country_name: nil

      expect(country).to_not be_valid
    end

    it 'with a duplicated name' do
      country = Country.new country_name: existing_country.country_name

      expect(country).to_not be_valid
    end
  end
end
