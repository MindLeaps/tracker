module Api
  class AssignmentsController < ApiController
    has_scope :after_timestamp
    has_scope :exclude_deleted, type: :boolean

    def index
      @assignments = apply_scopes(Assignment).all
      respond_with @assignments, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @assignment = Assignment.find params.require :id
      respond_with @assignment, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
