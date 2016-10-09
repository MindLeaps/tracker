# frozen_string_literal: true
module Api
  class OrganizationsController < ApiController
    def index
      @organizations = Organization.all
      respond_with @organizations
    end
  end
end
