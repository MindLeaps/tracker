module Api
  class OrganizationsController < ApiController
    has_scope :exclude_deleted, type: :boolean
    has_scope :after_timestamp

    def index
      @organizations = apply_scopes(@api_version == 2 ? policy_scope(Organization) : Organization).all
      respond_with @organizations, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @organization = Organization.find params.require :id
      respond_with @organization, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
