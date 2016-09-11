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
end
