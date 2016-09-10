require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:super_admin) { create :super_admin }

  before :each do
    sign_in super_admin
  end

  describe '#index' do
    it 'lists all existing users' do
      user1 = create :user, name: 'user one'
      user2 = create :user, name: 'user two'

      get :index
      expect(response).to be_success

      expect(assigns(:users)).to include user1
      expect(assigns(:users)).to include user2
    end
  end
end
