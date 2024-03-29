module Users
  class SessionsController < Devise::SessionsController
    skip_before_action :verify_authenticity_token

    def token_signin
      return render_invalid_token_error if params[:id_token].presence.nil?

      user = authenticate_user_from_token! params[:id_token].presence
      return render_invalid_user_error if user.nil?

      token = Tiddle.create_and_return_token(user, request)
      render json: { authentication_token: token }
    rescue OAuth2::Error
      render_invalid_token_error
    end

    private

    def render_invalid_token_error
      render json: { error: t(:invalid_token) }, status: :unauthorized
    end

    def authenticate_user_from_token!(token)
      user = User.from_id_token(token.to_s)
      sign_in user, store: false if user
    end

    def render_invalid_user_error
      render json: { error: t(:invalid_user) }, status: :forbidden
    end
  end
end
