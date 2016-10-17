# frozen_string_literal: true
module Api
  class GradeDescriptorsController < ApiController
    has_scope :after_timestamp
    has_scope :by_skill, as: :skill_id
    has_scope :exclude_deleted, type: :boolean

    def index
      @grade_descriptors = apply_scopes(GradeDescriptor).all
      respond_with @grade_descriptors, meta: { timestamp: Time.zone.now }
    end

    def show
      @grade_descriptor = GradeDescriptor.find params.require :id
      respond_with @grade_descriptor, meta: { timestamp: Time.zone.now }
    end
  end
end
