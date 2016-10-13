# frozen_string_literal: true
module Api
  class GradesController < ApiController
    has_scope :by_student, as: :student_id
    has_scope :by_lesson, as: :lesson_id
    has_scope :after_timestamp

    def index
      @grades = apply_scopes(Grade).all
      respond_with :api, @grades, meta: { timestamp: Time.zone.now }, include: []
    end

    def show
      @grade = Grade.find params[:id]
      respond_with :api, @grade, meta: { timestamp: Time.zone.now }, include: []
    end

    def create
      @grade = Grade.new grade_params
      @grade.save
      respond_with :api, @grade, meta: { timestamp: Time.zone.now }, include: []
    end

    private

    def grade_params
      params.permit(:student_id, :grade_descriptor_id, :lesson_id)
    end
  end
end
