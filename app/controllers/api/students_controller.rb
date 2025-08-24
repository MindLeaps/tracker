module Api
  class StudentsController < ApiController
    has_scope :after_timestamp
    has_scope :by_group, as: :group_id
    has_scope :by_organization, as: :organization_id
    has_scope :exclude_deleted, type: :boolean

    def index
      @students = apply_scopes(@api_version == 2 ? policy_scope(Student) : Student).includes(:enrollments).all
      respond_with @students, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @student = Student.find params[:id]
      respond_with @student, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
