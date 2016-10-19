# frozen_string_literal: true
module Api
  class AssignmentsController < ApiController
    def index
      @assignments = Assignment.all
      respond_with @assignments, meta: { timestamp: Time.zone.now }
    end

    def show
      @assignment = Assignment.find params.require :id
      respond_with @assignment, meta: { timestamp: Time.zone.now }
    end
  end
end
