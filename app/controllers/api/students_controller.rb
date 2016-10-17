# frozen_string_literal: true
module Api
  class StudentsController < ApiController
    has_scope :after_timestamp

    def index
      @students = if params[:group_id]
                    Student.where group_id: params[:group_id]
                  else
                    apply_scopes Student.all
                  end
      respond_with @students, meta: { timestamp: Time.zone.now }
    end

    def show
      @student = Student.find params[:id]
      respond_with @student, meta: { timestamp: Time.zone.now }
    end
  end
end
