class HtmlController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :better_errors_hack, if: -> { Rails.env.development? } # Hack to make better errors work with Puma
  after_action :verify_authorized, unless: :devise_controller?
  # rubocop:disable Rails/LexicallyScopedActionFilter
  after_action :verify_policy_scoped, only: :index
  # rubocop:enable Rails/LexicallyScopedActionFilter
  around_action :switch_locale

  def switch_locale(&)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &)
  end

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def session_path(*)
    new_user_session_path(*)
  end

  def flash_redirect(destination)
    if destination.nil?
      flash[:redirect] = nil
      return
    end

    uri = URI(destination)
    return unless uri.host == request.host

    flash[:redirect] = uri.path + (uri.query.present? ? "?#{uri.query}" : '')
  end

  def handle_turbo_failure_responses(error_flash_hash)
    respond_to do |format|
      format.turbo_stream do
        flash.now[:failure_notice] = error_flash_hash
        render :new, status: :unprocessable_content
      end
      format.html do
        flash[:failure_notice] = error_flash_hash
        render :new, status: :unprocessable_content
      end
    end
  end

  # rubocop:disable Metrics/ParameterLists
  def success(title:, text:, link_path: nil, link_text: nil, button_path: nil, button_text: nil, button_method: nil)
    flash[:success_notice] = {
      title:, text:, link_path:, link_text:, button_path:, button_method:, button_text:
    }
  end

  def success_now(title:, text:, link_path: nil, link_text: nil, button_path: nil, button_text: nil, button_method: nil)
    flash.now[:success_notice] = {
      title:, text:, link_path:, link_text:, button_path:, button_method:, button_text:
    }
  end

  def failure(title:, text:, link_path: nil, link_text: nil, button_path: nil, button_text: nil, button_method: nil)
    flash[:failure_notice] = {
      title:, text:, link_path:, link_text:, button_path:, button_method:, button_text:
    }
  end

  def failure_now(title:, text:, link_path: nil, link_text: nil, button_path: nil, button_text: nil, button_method: nil)
    flash.now[:failure_notice] = {
      title:, text:, link_path:, link_text:, button_path:, button_method:, button_text:
    }
  end
  # rubocop:enable Metrics/ParameterLists

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
