# frozen_string_literal: true

module Api
  class GradesController < ApiController
    has_scope :by_student, as: :student_id
    has_scope :by_lesson, as: :lesson_id
    has_scope :after_timestamp
    has_scope :exclude_deleted, type: :boolean
    has_scope :include_deleted_students, type: :boolean, default: false, allow_blank: true do |_, scope, value|
      !value ? scope.exclude_deleted_students : scope
    end

    def index
      @grades = apply_scopes(Grade).where('grades.updated_at > :datetime', datetime: 4.months.ago).all
      if @api_version == 2
        respond_with :api, @grades, meta: { timestamp: Time.zone.now }, include: included_params, each_serializer: GradeSerializerUUID
      else
        respond_with :api, @grades, meta: { timestamp: Time.zone.now }, include: included_params
      end
    end

    def show
      @grade = Grade.find params[:id]
      if @api_version == 2
        respond_with :api, @grade, meta: { timestamp: Time.zone.now }, include: included_params, serializer: GradeSerializerUUID
      else
        respond_with :api, @grade, meta: { timestamp: Time.zone.now }, include: included_params
      end
    end

    def create
      if @api_version == 2
        create_v2_grade
      else
        create_v1_grade
      end
    rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound
      head :bad_request
    end

    def update
      @grade = Grade.find params[:id]
      @grade.update grade_params
      # Needs json: attribute to render, otherwise does 204 for update by default
      if @api_version == 2
        respond_with :api, @grade, json: @grade, meta: { timestamp: Time.zone.now }, include: included_params, serializer: GradeSerializerUUID
      else
        respond_with :api, @grade, json: @grade, meta: { timestamp: Time.zone.now }, include: included_params
      end
    end

    def destroy
      @grade = Grade.find params[:id]
      @grade.update deleted_at: Time.zone.now
      # Needs json: attribute to render, otherwise does 204 for destroy by default
      respond_with :api, @grade, json: @grade, meta: { timestamp: Time.zone.now }, include: included_params
    end

    private

    def create_v2_grade
      grade = Grade.new grade_all_params_lesson_uuid
      Grade.transaction do
        grade.lesson = Lesson.find_by! uid: grade.lesson_uid
        grade = save_or_update_if_exists(grade)
      end
      respond_with :api, grade, meta: { timestamp: Time.zone.now }, include: included_params, serializer: GradeSerializerUUID unless performed?
    end

    def create_v1_grade
      grade = Grade.new grade_all_params
      grade = save_or_update_if_exists(grade)
      respond_with :api, grade, meta: { timestamp: Time.zone.now }, include: included_params unless performed?
    end

    def grade_params
      params.permit :student_id, :grade_descriptor_id, :lesson_id
    end

    def grade_lesson_uuid_params
      p = grade_params
      p[:lesson_uid] = p[:lesson_id]
      p.delete :lesson_id
      p
    end

    def grade_all_params
      params.require %i[student_id grade_descriptor_id lesson_id]
      grade_params
    end

    def grade_all_params_lesson_uuid
      params.require %i[student_id grade_descriptor_id lesson_id]
      grade_lesson_uuid_params
    end

    def save_or_update_if_exists(grade)
      Grade.transaction do
        return grade if grade.save

        existing_grade = grade.find_duplicate
        existing_grade.update grade_descriptor_id: grade.grade_descriptor_id
        if @api_version == 2
          respond_with :api, existing_grade, status: :ok, meta: { timestamp: Time.zone.now }, include: {}, serializer: GradeSerializerUUID
        else
          respond_with :api, existing_grade, status: :ok, meta: { timestamp: Time.zone.now }, include: {}
        end
      end
    end
  end
end
