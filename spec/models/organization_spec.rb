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

  describe '#add_user_with_role' do
    let(:org) { create :organization }

    it 'Adds a new user with a specified role in the organization' do
      expect(org.add_user_with_role('someone@example.com', :admin)).to be_truthy

      user = User.find_by email: 'someone@example.com'
      expect(user.has_role?(:admin)).to be false
      expect(user.has_role?(:admin, org)).to be true
    end

    it 'Does not add a new user if a passed role is invalid' do
      expect(org.add_user_with_role('someone@example.com', :nonexistant)).to be false

      expect(User.find_by(email: 'someone@example.com')).to be_nil
    end
  end

  describe '#members' do
    let(:org) { create :organization }
    let(:other_org) { create :organization }

    before :each do
      @members = create_list :teacher_in, 2, organization: org
      @non_members = create_list :teacher_in, 3, organization: other_org
      @members << create(:admin_of, organization: org)
    end

    it 'returns users who have a role in the organization' do
      expect(org.members.length).to eq 3
      expect(org.members).to include(*@members)
    end
  end
end
