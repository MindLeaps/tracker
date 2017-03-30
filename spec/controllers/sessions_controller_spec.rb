# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  describe '#token_signin' do
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @user = create :user, email: 'existing_user_email@example.com'
      @valid_token = 'abcdedgh12345'

      stub_request(:get, "#{Rails.configuration.google_token_info_url}?id_token=#{@valid_token}")
        .to_return(status: 200, body: JSON.unparse(email: @user.email), headers: { content_type: 'application/json' })
    end

    context 'with a valid token' do
      before :each do
        post :token_signin, params: { id_token: @valid_token }
      end

      it { should respond_with 200 }

      it 'responds with authentication token' do
        expect(json['authentication_token']).not_to be_empty
      end
    end

    context 'with an invalid token' do
      before :each do
        post :token_signin
      end

      it { should respond_with 401 }

      it 'displays error message' do
        expect(json['error']).to eq 'Invalid token or non-existent user'
      end
    end
  end
end
