# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  current_sign_in_at :datetime
#  current_sign_in_ip :string
#  email              :string           default(""), not null
#  image              :string
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :string
#  name               :string
#  provider           :string
#  sign_in_count      :integer          default(0), not null
#  uid                :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @user = create :user, email: 'existing_user_email@example.com'
  end

  describe '#from_id_token' do
    let(:id_token) { 'some_valid_google_id_token_123' }

    context 'user has a lowercase Google email address' do
      it 'returns a user identified by the email' do
        stub_request(:get, "#{Rails.configuration.google_token_info_url}?id_token=#{id_token}")
          .to_return(status: 200, body: JSON.unparse(email: @user.email), headers: { content_type: 'application/json' })

        expect(User.from_id_token(id_token)).to eq @user
      end
    end

    context 'user has a mixed case Google email address' do
      it 'returns a user identified by the email' do
        stub_request(:get, "#{Rails.configuration.google_token_info_url}?id_token=#{id_token}")
          .to_return(status: 200, body: JSON.unparse(email: @user.email.capitalize), headers: { content_type: 'application/json' })

        expect(User.from_id_token(id_token)).to eq @user
      end
    end
  end

  describe 'validations' do
    describe 'is valid' do
      it 'with a valid, unique email' do
        user = User.new email: 'some_unique_email@example.com'
        expect(user).to be_valid
        expect(user.email).to eql 'some_unique_email@example.com'
      end
    end

    describe 'is not valid' do
      let(:org) { create :organization }

      it 'without the email field' do
        user = User.new
        expect(user).to_not be_valid
      end

      it 'with an empty email field' do
        user = User.new email: ''
        expect(user).to_not be_valid
      end

      it 'with a duplicated email field' do
        user = User.new email: 'existing_user_email@example.com'
        expect(user).to_not be_valid
      end
    end
  end

  describe '#administrator?' do
    context 'when user is global super administrator' do
      let(:user) { create :super_admin }

      it 'is true globally' do
        expect(user.administrator?).to eq true
      end

      it 'is true for any organization' do
        organization = create :organization

        expect(user.administrator?(organization)).to eq true
      end
    end

    context 'user is global administrator' do
      let(:user) { create :global_admin }

      it 'is true globally' do
        expect(user.administrator?).to eq true
      end

      it 'is true for any organization' do
        organization = create :organization

        expect(user.administrator?(organization)).to eq true
      end
    end

    context 'user is a local administrator' do
      let(:organization) { create :organization }
      let(:user) { create :admin_of, organization: organization }

      it 'is true for an organization the user is admin of' do
        expect(user.administrator?(organization)).to eq true
      end

      it 'is true when no organization is passed' do
        expect(user.administrator?).to eq true
      end

      it 'is false for an organization the user is not an admin of' do
        organization2 = create :organization

        expect(user.administrator?(organization2)).to eq false
      end
    end

    context 'user is a regular user' do
      let(:user) { create :user }

      it 'is false globally' do
        expect(user.administrator?).to eq false
      end

      it 'is false for any given organization' do
        organization = create :organization

        expect(user.administrator?(organization)).to eq false
      end
    end
  end

  describe '#membership_organizations' do
    subject { user.membership_organizations }
    let(:org) { create :organization }
    let(:org2) { create :organization }
    let(:user) { create :admin_of, organization: org }

    context 'user is a member of only one organization' do
      it 'returns an array containing one organization' do
        expect(subject.length).to eq 1
        expect(subject).to include org
      end
    end

    context 'user is an admin of one organization and teacher in another' do
      it 'returns an array containing both organizations' do
        RoleService.update_local_role user, :teacher, org2

        expect(subject.length).to eq 2
        expect(subject).to include org, org2
      end
    end
  end

  describe '#organizations' do
    subject { user.organizations }
    context 'user is an admin of one organization' do
      let(:org) { create :organization }
      let(:user) { create :admin_of, organization: org }

      it 'returns an array containing only the user\'s organization' do
        expect(subject.length).to eq 1
        expect(subject).to include org
      end
    end
    context 'user is an admin of one organization and a teacher in another' do
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:user) { create :admin_of, organization: org1 }
      before :each do
        RoleService.update_local_role user, :teacher, org2
      end

      it 'returns an array containing both organizations' do
        expect(subject.length).to eq 2
        expect(subject).to include org1, org2
      end
    end
    context 'user is a global admin' do
      let(:user) { create :global_admin }
      before :each do
        @org1 = create :organization
        @org2 = create :organization
        @org3 = create :organization
      end

      it 'returns an array containing all 3 organizations' do
        expect(subject).to include @org1, @org2, @org3
      end
    end
    context 'user is a global researcher' do
      let(:user) { create :global_researcher }
      before :each do
        @org1 = create :organization
        @org2 = create :organization
        @org3 = create :organization
      end

      it 'returns an array containing all 3 organizations' do
        expect(subject).to include @org1, @org2, @org3
      end
    end
  end

  describe '#global_administrator?' do
    subject { user.global_administrator? }
    context 'user is global Super Administrator' do
      let(:user) { create :super_admin }

      it { is_expected.to be true }
    end
    context 'user is global Administrator' do
      let(:user) { create :global_admin }

      it { is_expected.to be true }
    end
    context 'user is administrator of an organizations' do
      let(:org) { create :organization }
      let(:user) { create :admin_of, organization: org }

      it { is_expected.to be false }
    end
  end

  describe '#role_level_in' do
    subject { user.role_level_in(current_org) }
    let(:current_org) { create :organization }

    context 'user is a global super admin' do
      let(:user) { create :super_admin }

      it { is_expected.to eq Role::ROLE_LEVELS[:super_admin] }
    end

    context 'user is a global admin' do
      let(:user) { create :global_admin }

      it { is_expected.to eq Role::ROLE_LEVELS[:global_admin] }
    end

    context 'user is an admin in current organization' do
      let(:user) { create :admin_of, organization: current_org }

      it { is_expected.to eq Role::ROLE_LEVELS[:admin] }
    end

    context 'user has no global roles, nor a role in the current organization' do
      let(:org2) { create :organization }
      let(:user) { create :teacher_in, organization: org2 }

      it { is_expected.to eq Role::MINIMAL_ROLE_LEVEL }
    end
  end

  describe '#global_role_level' do
    subject { user.global_role_level }

    context 'user is a global super admin' do
      let(:user) { create :super_admin }
      it { is_expected.to eq Role::ROLE_LEVELS[:super_admin] }
    end

    context 'user is a global admin' do
      let(:user) { create :global_admin }
      it { is_expected.to eq Role::ROLE_LEVELS[:global_admin] }
    end

    context 'user is a local admin' do
      let(:org) { create :organization }
      let(:user) { create :admin_of, organization: org }

      it { is_expected.to eq Role::MINIMAL_ROLE_LEVEL }
    end
  end

  describe '#role_in' do
    let(:org) { create :organization }
    let(:org2) { create :organization }

    context 'user is an admin of the organization' do
      let(:user) { create :admin_of, organization: org }

      it 'returns user\'s admin role in the organization' do
        expect(user.role_in(org)).to eq user.roles.first
      end

      context 'user is also a teacher in another organization' do
        before { RoleService.update_local_role user, :teacher, org2 }

        it 'returns user\'s teacher role in second organization' do
          expect(user.role_in(org2)).to eq user.roles.find_by resource_id: org2.id, name: 'teacher'
        end
      end
    end

    context 'user is a global admin' do
      let(:user) { create :global_admin }

      it 'returns nil' do
        expect(user.role_in(org)).to be_nil
      end
    end
  end

  describe '#member_of' do
    let(:org) { create :organization }
    let(:org2) { create :organization }
    let(:user) { create :admin_of, organization: org }
    let(:user2) { create :teacher_in, organization: org2 }
    let(:global_user) { create :super_admin }

    it { expect(user.member_of?(org)).to be true }
    it { expect(user.member_of?(org2)).to be false }

    it { expect(user2.member_of?(org)).to be false }
    it { expect(user2.member_of?(org2)).to be true }

    it { expect(global_user.member_of?(org)).to be false }
    it { expect(global_user.member_of?(org2)).to be false }
  end

  describe 'global_roles?' do
    let(:org) { create :organization }

    it 'is true for users with a global role' do
      user = create :super_admin
      expect(user.global_role?).to be true
      user = create :global_admin
      expect(user.global_role?).to be true
      user = create :global_guest
      expect(user.global_role?).to be true
    end

    it 'is false for users without a global role' do
      user = create :teacher_in, organization: org
      expect(user.global_role?).to be false
      user = create :admin_of, organization: org
      expect(user.global_role?).to be false
    end
  end

  describe '#read_only?' do
    subject { user.read_only? }
    let(:org) { create :organization }

    context 'User is a Global Guest' do
      let(:user) { create :global_guest }

      it { is_expected.to be true }
    end

    context 'User is a Global Admin' do
      let(:user) { create :global_admin }

      it { is_expected.to be false }
    end

    context 'User is a local teacher' do
      let(:user) { create :teacher_in, organization: org }

      it { is_expected.to be false }
    end

    context 'User is a global researcher' do
      let(:user) { create :global_researcher }

      it { is_expected.to be true }
    end

    context 'User is a global administrator and local researcher' do
      let(:user) { create(:global_admin).tap { |u| u.add_role :researcher, org } }

      it { is_expected.to be false }
    end

    context 'User is a global researcher and local admin' do
      let(:user) { create(:global_researcher).tap { |u| u.add_role :admin, org } }

      it { is_expected.to be false }
    end
  end

  describe 'scopes' do
    describe 'search' do
      before :each do
        @user1 = create :user, name: 'Alojandro Umberto', email: 'aumberto@example.com'
        @user2 = create :user, name: 'Aloemawe Uracca', email: 'aurraca@example.com'
        @user3 = create :user, name: 'Imberato Umberto', email: 'iumberto@example.com'
      end

      it 'searches for the user by a partial name match' do
        result = User.search('Alojandro')
        expect(result.length).to eq 1
        expect(result).to include @user1

        result = User.search('Alo')
        expect(result.length).to eq 2
        expect(result).to include @user1, @user2

        result = User.search('Umb')
        expect(result.length).to eq 2
        expect(result).to include @user1, @user3
      end

      it 'searches for the user by a partial email match' do
        result = User.search('aumberto')
        expect(result.length).to eq 1
        expect(result).to include @user1
      end
    end
  end
end
