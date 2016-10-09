# frozen_string_literal: true
module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :authenticate_user!

    def google_oauth2
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: '  Google') if is_navigational_format?
      else
        failure
      end
    end

    def failure
      flash[:alert] = I18n.t('devise.failure.unauthenticated')
      redirect_to root_path
    end
  end
end
