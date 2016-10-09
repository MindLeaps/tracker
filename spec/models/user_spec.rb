# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  before :all do
    create :user, email: 'existing_user_email@example.com'
  end

  describe 'is valid' do
    it 'with a valid, unique email' do
      user = User.new email: 'some_unique_email@example.com'
      expect(user).to be_valid
      expect(user.email).to eql 'some_unique_email@example.com'
    end
  end

  describe 'is not valid' do
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
    context 'user is an admin of one organization and a user of another' do
      let(:org1) { create :organization }
      let(:org2) { create :organization }
      let(:user) { create :admin_of, organization: org1 }
      before :each do
        user.add_role :user, org2
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
end
