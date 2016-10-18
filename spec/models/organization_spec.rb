# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Organization, type: :model do
  before :each do
    create :organization, organization_name: 'Already Existing Organization'
  end

  it { should have_many :chapters }
  it { should have_many :students }

  describe 'is valid' do
    it 'with a valid, unique name' do
      org = Organization.new organization_name: 'Totally valid org'
      expect(org).to be_valid
      expect(org.organization_name).to eql 'Totally valid org'
    end
  end

  describe 'is not valid' do
    it 'without organization name' do
      org = Organization.new organization_name: nil
      expect(org).to_not be_valid
    end

    it 'with a duplicated name' do
      org = Organization.new organization_name: 'Already Existing Organization'
      expect(org).to_not be_valid
    end
  end
end
