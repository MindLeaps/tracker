# frozen_string_literal: true
module Api
  class OrganizationsController < ApiController
    has_scope :exclude_deleted, type: :boolean

    def index
      @organizations = apply_scopes(Organization).all
      respond_with @organizations, meta: { timestamp: Time.zone.now }
    end

    def show
      @organization = Organization.find params.require :id
      respond_with @organization, meta: { timestamp: Time.zone.now }
    end
  end
end
