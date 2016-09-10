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
end
