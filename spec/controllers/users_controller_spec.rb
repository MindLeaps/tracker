# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:super_admin) { create :super_admin }

  before :each do
    sign_in super_admin
  end

  describe '#index' do
    before :each do
      get :index
      @users = create_list :user, 3
    end
    it { should respond_with 200 }

    it 'lists all existing users' do
      get :index
      expect(response).to be_success

      expect(assigns(:users)).to include(*@users)
    end
  end

  describe '#new' do
    before :each do
      get :new
    end

    it { should respond_with 200 }
    it { should render_template 'new' }
    it 'assigns an empty User for the form' do
      expect(assigns(:user)).to be_a_kind_of(User)
    end
  end

  describe '#create' do
    before :each do
      post :create, params: {
        user: { email: 'new_user@example.com' }
      }
    end

    it { should redirect_to users_path }
    it { should set_flash[:notice].to 'User with email new_user@example.com added.' }

    it 'creates a new user' do
      expect(User.last.email).to eq 'new_user@example.com'
    end
  end
end
