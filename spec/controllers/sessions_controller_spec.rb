require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  describe '#token_signin' do
    before :each do
      @request.env['devise.mapping'] = Devise.mappings[:user]
      @user_email = 'existing_user_email@example.com'
      @valid_token = 'VALID'
      @invalid_token = 'INVALID'
    end

    context 'with a valid Google id_token' do
      before :each do
        stub_request(:get, "#{Rails.configuration.google_token_info_url}?id_token=#{@valid_token}")
          .to_return(status: 200, body: JSON.unparse(email: @user_email), headers: { content_type: 'application/json' })
      end

      context 'User exists' do
        before :each do
          @user = create :user, email: @user_email
          post :token_signin, params: { id_token: @valid_token }
        end
        it { should respond_with 200 }

        it 'responds with authentication token' do
          expect(json['authentication_token']).not_to be_empty
        end
      end

      context 'User does not exist' do
        before :each do
          post :token_signin, params: { id_token: @valid_token }
        end
        it { should respond_with 403 }

        it 'displays error message' do
          expect(json['error']).to eq 'User does not exist in MindLeaps'
        end
      end
    end

    context 'with an invalid Google id_token' do
      before :each do
        stub_request(:get, "#{Rails.configuration.google_token_info_url}?id_token=#{@invalid_token}")
          .to_return(status: 500, body: JSON.unparse(error_description: 'Invalid Value'), headers: { content_type: 'application/json' })

        post :token_signin, params: { id_token: @invalid_token }
      end

      it { should respond_with 401 }

      it 'displays error message' do
        expect(json['error']).to eq 'Invalid Google id_token'
      end
    end

    context 'without a Google id_token' do
      before :each do
        post :token_signin
      end

      it { should respond_with 401 }

      it 'displays error message' do
        expect(json['error']).to eq 'Invalid Google id_token'
      end
    end
  end
end
