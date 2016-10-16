# frozen_string_literal: true
module Api
  class GradeDescriptorsController < ApiController
    def index
      @grade_descriptors = GradeDescriptor.all
      respond_with @grade_descriptors, meta: { timestamp: Time.zone.now }
    end

    def show
      @grade_descriptor = GradeDescriptor.find params.require :id
      respond_with @grade_descriptor, meta: { timestamp: Time.zone.now }
    end
  end
end
