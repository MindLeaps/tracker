# frozen_string_literal: true

class BaseController < ActionController::Base
  include Pundit
  before_action :authenticate_user!

  def append_info_to_payload(payload)
    super
    payload[:user_email] = current_user.try :email
  end
end
