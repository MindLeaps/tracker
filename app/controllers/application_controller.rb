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

  def undo_notice_and_redirect(notice, undo_path, redirect_url)
    undo_link = view_context.button_to 'Undo', undo_path, class: 'notice-link alert-link btn-link'
    flash[:undo_notice] = notice + " #{undo_link}"
    redirect_to redirect_url
  end

  def link_notice_and_redirect(notice, link_path, link_text, redirect_url)
    link = view_context.link_to link_text, link_path, class: 'notice-link alert-link btn-link'
    flash[:link_notice] = notice + " #{link}"
    redirect_to redirect_url
  end

  add_flash_types :undo_notice, :link_notice

  helper_method :session_path
end
