require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  fixtures :users
  include_context 'controller_login'

  describe '#index' do
    it 'lists all existing users' do
      get :index
      expect(response).to be_success

      expect(assigns(:users)).to include users(:teacher_one)
      expect(assigns(:users)).to include users(:teacher_two)
    end
  end
end
