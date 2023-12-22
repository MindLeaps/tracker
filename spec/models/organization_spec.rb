# frozen_string_literal: true

# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  deleted_at        :datetime
#  image             :string           default("https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200")
#  mlid              :string(3)        not null
#  organization_name :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  organizations_mlid_key  (mlid) UNIQUE
#
require 'rails_helper'

RSpec.describe Organization, type: :model do
  let(:existing_org) { create :organization, organization_name: 'Already Existing Organization' }

  it { should have_many :chapters }

  describe 'is valid' do
    it 'with a valid, unique name and a unique MLID' do
      org = Organization.new organization_name: 'Totally valid org', mlid: 'uni'
      expect(org).to be_valid
      expect(org.organization_name).to eql 'Totally valid org'
      expect(org.mlid).to eql 'uni'
    end
  end

  describe 'is not valid' do
    it 'without organization name' do
      org = Organization.new organization_name: nil, mlid: 'ABC'
      expect(org).to_not be_valid
    end

    it 'without an MLID' do
      org = Organization.new organization_name: 'Some org', mlid: nil
      expect(org).to_not be_valid
    end

    it 'with a duplicated name' do
      org = Organization.new organization_name: existing_org.organization_name, mlid: '1J4'
      expect(org).to_not be_valid
    end

    it 'with a duplicated MLID' do
      org = Organization.new organization_name: 'Some other org', mlid: existing_org.mlid
      expect(org).to_not be_valid
    end

    it 'with an MLID containing special characters' do
      org = Organization.new organization_name: 'Another org', mlid: 'AV?'
      expect(org).to_not be_valid
    end

    it 'with an MLID that is longer than 3 characters' do
      org = Organization.new organization_name: 'Another org', mlid: 'AVBV'
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
      expect(org.members).to include(OrganizationMember.find(@members[0].id))
      expect(org.members).to include(OrganizationMember.find(@members[1].id))
      expect(org.members).to include(OrganizationMember.find(@members[2].id))
    end
  end
end
