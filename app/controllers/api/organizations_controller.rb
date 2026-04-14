module Api
  class OrganizationsController < ApiController
    has_scope :exclude_deleted, type: :boolean
    has_scope :after_timestamp

    def index
      @organizations = apply_scopes(versioned_scope(Organization, policy_versions: [2])).all
      respond_with @organizations, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @organization = Organization.find params.require :id
      respond_with @organization, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
