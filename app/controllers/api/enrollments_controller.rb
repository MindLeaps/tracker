module Api
  class EnrollmentsController < ApiController
    has_scope :after_timestamp
    has_scope :by_group, as: :group_id
    has_scope :by_student, as: :student_id

    def index
      @enrollments = apply_scopes(@api_version == 2 ? policy_scope(Enrollment) : Enrollment).all
      respond_with @enrollments, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @enrollment = Enrollment.find params[:id]
      respond_with @enrollment, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
