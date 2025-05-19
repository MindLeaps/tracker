module Api
  class EnrollmentsController < ApiController
    has_scope :after_timestamp
    has_scope :by_group, as: :group_id
    has_scope :by_student, as: :student_id

    def index
      @enrollments = apply_scopes([2, 3].include?(@api_version) ? policy_scope(Enrollment) : Enrollment).all
      if @api_version == 3
        respond_with @enrollments, include: included_params, meta: { timestamp: Time.zone.now }, each_serializer: EnrollmentSerializerV2
      else
        respond_with @enrollments, include: included_params, meta: { timestamp: Time.zone.now }, each_serializer: EnrollmentSerializer
      end
    end

    def show
      @enrollment = Enrollment.find params[:id]
      respond_with @enrollment, include: included_params, meta: { timestamp: Time.zone.now }
    end
  end
end
