# frozen_string_literal: true

class DrawerComponent < ViewComponent::Base
  def initialize(current_user:)
    @current_user = current_user
  end

  def user_image
    helpers.current_user_image
  end

  def current_user_path
    user_path(@current_user)
  end

  def current_user_email
    @current_user.email
  end
end
