# frozen_string_literal: true

module Api
  class ApiController < ApplicationController
    before_action :skip_session_cookie
    before_action :set_api_version
    protect_from_forgery with: :null_session
    respond_to :json

    protected

    def included_params
      return [] if params[:include].nil?

      params['include'].split(',').map(&:strip)
    end

    def skip_session_cookie
      request.session_options[:skip] = true
    end

    def set_api_version
      accept_header = request.headers['Accept']
      return if accept_header.nil?

      capture = accept_header.match(/version=(\d+)/).try(:captures)
      return if capture.nil?

      @api_version = capture[0].to_i
    end
  end
end
