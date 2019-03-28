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
      authorize Lesson
      @grades = apply_scopes(Grade).where('grades.updated_at > :datetime', datetime: 4.months.ago).all
      if @api_version == 2
        respond_with :api, @grades, meta: { timestamp: Time.zone.now }, include: included_params, each_serializer: GradeSerializerV2
      else
        respond_with :api, @grades, meta: { timestamp: Time.zone.now }, include: included_params
      end
    end

    def show
      if @api_version == 2
        @grade = Grade.includes(:lesson).find_by uid: params.require(:id)
        authorize @grade.lesson
        respond_with :api, @grade, meta: { timestamp: Time.zone.now }, include: included_params, serializer: GradeSerializerV2
      else
        @grade = Grade.find params.require(:id)
        respond_with :api, @grade, meta: { timestamp: Time.zone.now }, include: included_params
      end
    end

    def create
      grade = Grade.new grade_all_params
      Grade.transaction do
        grade.grade_descriptor = GradeDescriptor.find grade.grade_descriptor_id
        grade = save_or_update_if_exists(grade) { |existing_grade| respond_with :api, existing_grade, status: :ok, meta: { timestamp: Time.zone.now }, include: {} }
      end
      respond_with :api, grade, meta: { timestamp: Time.zone.now }, include: included_params unless performed?
    rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound
      head :bad_request
    end

    def put_v2
      grade = build_grade
      authorize grade.lesson, :create?
      Grade.transaction do
        grade.grade_descriptor = GradeDescriptor.find_by skill_id: grade.skill_id, mark: grade.mark
        grade = save_or_update_if_exists(grade) { |existing_grade| respond_with :api, existing_grade, json: existing_grade, status: :ok, meta: { timestamp: Time.zone.now }, include: {}, serializer: GradeSerializerV2 }
      end
      respond_with :api, grade, json: grade, status: :created, meta: { timestamp: Time.zone.now }, include: included_params, serializer: GradeSerializerV2 unless performed?
    rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound
      head :bad_request
    end

    def update
      @grade = Grade.find params.require :id
      @grade.update grade_params
      respond_with :api, @grade, json: @grade, meta: { timestamp: Time.zone.now }, include: included_params
    end

    def destroy
      @grade = Grade.find params.require :id
      @grade.update deleted_at: Time.zone.now
      # Needs json: attribute to render, otherwise does 204 for destroy by default
      respond_with :api, @grade, json: @grade, meta: { timestamp: Time.zone.now }, include: included_params
    end

    def destroy_v2
      @grade = Grade.includes(:lesson)
                    .find_by student_id: params.require(:student_id), lesson_id: params.require(:lesson_id), skill_id: params.require(:skill_id)
      authorize @grade.lesson, :destroy?
      @grade.update deleted_at: Time.zone.now
      respond_with :api, @grade, json: @grade, meta: { timestamp: Time.zone.now }, include: included_params, serializer: GradeSerializerV2
    end

    private

    def build_grade
      grade = Grade.new grade_v2_all_params
      grade.lesson = Lesson.find_by! uid: grade.lesson_uid
      grade
    end

    def grade_params
      params.permit :student_id, :grade_descriptor_id, :lesson_id
    end

    def grade_all_params
      params.require %i[student_id grade_descriptor_id lesson_id]
      grade_params
    end

    def grade_v2_all_params
      params.require %i[student_id lesson_id skill_id mark]
      p = params.permit :student_id, :mark, :skill_id, :lesson_id
      p[:lesson_uid] = p[:lesson_id]
      p.delete :lesson_id
      p
    end

    def save_or_update_if_exists(grade)
      Grade.transaction do
        return grade if grade.save

        existing_grade = grade.find_duplicate
        existing_grade.update grade_descriptor: grade.grade_descriptor, deleted_at: nil
        yield existing_grade
      end
    end
  end
end
