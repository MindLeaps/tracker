# frozen_string_literal: true
module Api
  class StudentsController < ApiController
    has_scope :after_timestamp
    has_scope :by_group, as: :group_id
    has_scope :by_organization, as: :organization_id

    def index
      @students = apply_scopes(Student).all
      respond_with @students, meta: { timestamp: Time.zone.now }
    end

    def show
      @student = Student.find params[:id]
      respond_with @student, meta: { timestamp: Time.zone.now }
    end
  end
end
