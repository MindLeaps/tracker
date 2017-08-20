# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before :each do
    @user = create :user, email: 'existing_user_email@example.com'
  end

  describe '#from_id_token' do
    before :each do
      @valid_token = 'some_valid_google_id_token_123'
      stub_request(:get, "#{Rails.configuration.google_token_info_url}?id_token=#{@valid_token}")
        .to_return(status: 200, body: JSON.unparse(email: @user.email), headers: { content_type: 'application/json' })
    end

    it 'returns a user identified by the email' do
      expect(User.from_id_token(@valid_token)).to eq @user
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

  describe '#grant_role_in' do
    let(:org1) { create :organization }
    let(:org2) { create :organization }
    let(:user) { create :user }

    it 'grants a role in the specified organization' do
      user.grant_role_in :teacher, org1

      expect(user.has_role?(:teacher, org1)).to eq true
    end

    it 'grants roles in multiple organizations' do
      user.grant_role_in :teacher, org1
      user.grant_role_in :admin, org2

      expect(user.has_role?(:teacher, org1)).to eq true
      expect(user.has_role?(:admin, org2)).to eq true
    end

    it 'does not grant more than one role in a single organization' do
      user.grant_role_in :teacher, org1
      user.grant_role_in :admin, org1

      expect(user.has_role?(:teacher, org1)).to eq true
      expect(user.has_role?(:admin, org1)).to eq false
    end

    it 'does not grant a role that is not specified in the Role::ROLES hash' do
      user.grant_role_in :nonexistant, org1

      expect(user.has_role?(:nonexistant, org1)).to eq false
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
      let(:user) { create :admin }

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

      it 'is false for an organization the user is not an admin of' do
        organization2 = create :organization

        expect(user.administrator?(organization2)).to eq false
      end

      it 'is false globally' do
        expect(user.administrator?).to eq false
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
        user.grant_role_in :teacher, org2

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
        user.grant_role_in :teacher, org2
      end

      it 'returns an array containing both organizations' do
        expect(subject.length).to eq 2
        expect(subject).to include org1, org2
      end
    end
    context 'user is a global admin' do
      let(:user) { create :admin }
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
      let(:user) { create :admin }

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
      let(:user) { create :admin }

      it { is_expected.to eq Role::ROLE_LEVELS[:admin] }
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

  describe '#global_roles' do
    subject { user.global_roles }
    let(:org) { create :organization }

    context 'user is a global super admin' do
      let(:user) { create :super_admin }

      it { is_expected.to contain_exactly(*user.roles.all) }
    end

    context 'user is a global admin and a local teacher' do
      let(:user) { create :admin }

      it 'contains only global admin role' do
        user.grant_role_in :teacher, org
        expect(subject).to(contain_exactly(*user.roles.where(name: :admin)))
      end
    end

    context 'user is a local teacher' do
      let(:user) { create :teacher_in, organization: org }

      it { is_expected.to match_array [] }
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
        before { user.grant_role_in :teacher, org2 }

        it 'returns user\'s teacher role in second organization' do
          expect(user.role_in(org2)).to eq user.roles.find_by resource_id: org2.id, name: 'teacher'
        end
      end
    end

    context 'user is a global admin' do
      let(:user) { create :admin }

      it 'returns nil' do
        expect(user.role_in(org)).to be_nil
      end
    end
  end

  describe '#update_role_in' do
    let(:org) { create :organization }
    let(:user) { create :teacher_in, organization: org }

    context 'updates the user\'s role from teacher to admin of an organization' do
      it 'removes the user\'s old teacher role' do
        user.update_role_in(:admin, org)
        expect(user.has_role?(:teacher, org)).to be false
      end

      it 'grants the user a new admin role ' do
        user.update_role_in(:admin, org)
        expect(user.has_role?(:admin, org)).to be true
      end

      it 'returns true' do
        expect(user.update_role_in(:admin, org)).to be true
      end
    end

    context 'tries to perform an invalid role update' do
      it 'does not remove the old teacher role' do
        user.update_role_in(:nonexist, org)
        expect(user.has_role?(:teacher, org)).to be true
      end

      it 'does not grant a new nonexist role' do
        user.update_role_in(:nonexist, org)
        expect(user.has_role?(:nonexist, org)).to be false
      end

      it 'returns false' do
        expect(user.update_role_in(:nonexist, org)).to be false
      end
    end
  end
end
