# frozen_string_literal: true
module Api
  class GradesController < ApiController
    def show
      @grade = Grade.find params[:id]
      respond_with @grade
    end

    def create
      @grade = Grade.new grade_params
      @grade.save
      respond_with :api, @grade
    end

    private
    def grade_params
      params.permit(:student_id, :grade_descriptor_id, :lesson_id)
    end
  end
end
