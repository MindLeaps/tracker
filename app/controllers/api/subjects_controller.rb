# frozen_string_literal: true
module Api
  class SubjectsController < ApiController
    has_scope :after_timestamp

    has_scope :by_organization, as: :organization_id

    def index
      @subjects = apply_scopes(Subject).all
      respond_with @subjects, include: ['lessons'], meta: { timestamp: Time.zone.now }
    end

    def show
      @subject = Subject.find params.require 'id'
      respond_with @subject, include: included_params, meta: { timestamp: Time.zone.now }
    end

    private

    def included_params
      return [] if params[:include].nil?

      params['include'].split(',').map(&:strip)
    end
  end
end
