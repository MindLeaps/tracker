# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:super_admin) { create :super_admin }

  before :each do
    sign_in super_admin
  end

  describe '#index' do
    context 'regular visit' do
      before :each do
        get :index
        @users = create_list :user, 3
      end
      it { should respond_with 200 }

      it 'lists all existing users' do
        get :index
        expect(response).to be_successful

        expect(assigns(:users)).to include(*@users)
      end
    end

    context 'search visit' do
      before :each do
        @user1 = create :user, name: 'Alojandro Umberto', email: 'aumberto@example.com'
        @user2 = create :user, name: 'Aloemawe Uracca', email: 'aurraca@example.com'
        @user3 = create :user, name: 'Imberato Umberto', email: 'iumberto@example.com'
      end

      it 'lists searched users by name' do
        get :index, params: { search: 'alo' }

        expect(assigns(:users).length).to eq 2
        expect(assigns(:users)).to include @user1, @user2
      end

      it 'lists searched users by email' do
        get :index, params: { search: 'iumbe' }

        expect(assigns(:users).length).to eq 1
        expect(assigns(:users)).to include @user3
      end
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

  describe '#create_token' do
    before :each do
      @user = create :user
      sign_in @user
    end

    it 'creates an authentication token for the user with TTL of one hour' do
      post :create_api_token, params: {
        id: @user.id
      }
      expect(@user.reload.authentication_tokens.length).to eq(1)
      expect(@user.reload.authentication_tokens[0].expires_in).to eq(3600)
    end

    it 'deletes the existing authentication tokens' do
      create_list :authentication_token, 3, user: @user

      post :create_api_token, params: {
        id: @user.id
      }

      expect(@user.reload.authentication_tokens.length).to eq(1)
    end

    context 'response' do
      before :each do
        post :create_api_token, params: {
          id: @user.id
        }
      end

      it { should respond_with 201 }
      it { should render_template :show }
      it 'assigns the token for template to render' do
        expect(assigns(:token)).to be_truthy
      end
    end
  end
end
