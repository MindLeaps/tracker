# frozen_string_literal: true
module Api
  class ApiController < ActionController::Base
    # before_action :authenticate_user!
    # before_action :skip_session_cookie

    include Pundit
    # Prevent CSRF attacks by raising an exception.
    # For APIs, you may want to use :null_session instead.
    # protect_from_forgery with: :null_session
    respond_to :json

    protected

    def included_params
      return [] if params[:include].nil?

      params['include'].split(',').map(&:strip)
    end

    def skip_session_cookie
      request.session_options[:skip] = true
    end
  end
end
