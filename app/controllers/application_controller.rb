# frozen_string_literal: true
class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def session_path(*args)
    new_user_session_path(*args)
  end

  def notice_and_redirect(notice, redirect_url)
    flash[:notice] = notice
    redirect_to redirect_url
  end

  helper_method :session_path
end
