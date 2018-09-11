# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    skip_before_action :verify_authenticity_token

    def token_signin
      user = authenticate_user_from_token! params[:id_token].presence
      return render json: { error: I18n.t(:invalid_token) }, status: :unauthorized if user.nil?

      token = Tiddle.create_and_return_token(user, request)
      render json: { authentication_token: token }
    end

    private

    def authenticate_user_from_token!(token)
      return nil unless token

      user = User.from_id_token(token.to_s)
      sign_in user, store: false if user
    end
  end
end
