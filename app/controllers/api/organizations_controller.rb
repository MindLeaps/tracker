# frozen_string_literal: true

module Api
  class OrganizationsController < ApiController
    has_scope :exclude_deleted, type: :boolean
    # has_scope :after_timestamp: we ignore the after_timestamp scope for organizations API. We want to always return all organizations the client has access to
    after_action :verify_policy_scoped, only: :index

    def index
      @organizations = apply_scopes(policy_scope(Organization)).all
      respond_with @organizations, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @organization = Organization.find params.require :id
      respond_with @organization, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
