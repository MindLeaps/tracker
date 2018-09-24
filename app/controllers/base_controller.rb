# frozen_string_literal: true

class BaseController < ActionController::Base
  include Pundit
  before_action :authenticate_user!

  def append_info_to_payload(payload)
    super
    payload[:user_email] = current_user.try :email
  end

  # Uncomment this to skip authentication in development
  # def authenticate_user!
  #   return true if Rails.env.development?
  #
  #   raise SecurityError
  # end
  #
  # def current_user
  #   raise SecurityError unless Rails.env.development?
  #
  #   user = User.find_or_create_by!(email: 'test@example.com')
  #   user.add_role :super_admin
  #   user
  # end
end
