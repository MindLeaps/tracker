# frozen_string_literal: true

class ApplicationController < BaseController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :better_errors_hack, if: -> { Rails.env.development? } # Hack to make better errors work with Puma
  after_action :verify_authorized, unless: :devise_controller?
  # rubocop:disable Rails/LexicallyScopedActionFilter
  after_action :verify_policy_scoped, only: :index
  # rubocop:enable Rails/LexicallyScopedActionFilter
  around_action :switch_locale

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def session_path(*args)
    new_user_session_path(*args)
  end

  def notice_and_redirect(notice, redirect_url)
    flash[:notice] = notice
    redirect_to redirect_url
  end

  def undo_notice_and_redirect(notice, undo_path, redirect_url)
    flash[:undo_notice] = { text: notice, path: undo_path }
    redirect_to redirect_url
  end

  def link_notice_and_redirect(notice, link_path, link_text, redirect_url)
    link = view_context.link_to link_text, link_path, class: 'notice-link alert-link btn-link'
    flash[:link_notice] = notice + " #{link}"
    redirect_to redirect_url
  end

  def user_not_authorized
    flash[:alert] = I18n.t :unauthorized_logout
    sign_out current_user
    render :unauthorized, status: :unauthorized, layout: false
  end

  add_flash_types :undo_notice, :link_notice

  helper_method :session_path

  private

  # On Puma 3.x, better errors tries to serialize all of Puma's variables, which includes a massive > 2MB :app variable
  # which is completely useless for debugging and causes long loading times; therefore, we remove it.
  # More info: https://github.com/charliesome/better_errors/issues/341
  def better_errors_hack
    request.env['puma.config'].options.user_options.delete(:app) if request.env.key?('puma.config')
  end
end
