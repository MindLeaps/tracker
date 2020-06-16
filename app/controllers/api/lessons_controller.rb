# frozen_string_literal: true

module Api
  class LessonsController < ApiController
    has_scope :after_timestamp
    has_scope :by_group, as: :group_id
    has_scope :by_subject, as: :subject_id

    def index
      @lessons = apply_scopes(@api_version == 2 ? policy_scope(Lesson) : Lesson).all
      if @api_version == 2
        authorize Lesson
        respond_with @lessons, include: included_params, meta: { timestamp: Time.zone.now }, each_serializer: LessonSerializerUuid
      else
        respond_with @lessons, include: included_params, meta: { timestamp: Time.zone.now }
      end
    end

    def show
      if @api_version == 2
        @lesson = Lesson.find_by uid: params.require(:id)
        respond_with @lesson, include: included_params, meta: { timestamp: Time.zone.now }, serializer: LessonSerializerUuid
      else
        @lesson = Lesson.find params.require :id
        respond_with @lesson, include: included_params, meta: { timestamp: Time.zone.now }
      end
    end

    def create
      lesson = Lesson.new @api_version == 2 ? lesson_params_with_uuid_as_id : lesson_params
      authorize lesson if @api_version == 2
      save_lesson lesson

      return if performed?

      if @api_version == 2
        respond_with lesson.reload, meta: { timestamp: Time.zone.now }, serializer: LessonSerializerUuid, location: api_lesson_url(id: lesson.uid)
      else
        respond_with lesson, meta: { timestamp: Time.zone.now }
      end
    end

    private

    def lesson_params_with_uuid_as_id
      p = params.permit :id, :group_id, :date, :subject_id
      p[:uid] = p[:id]
      p.delete :id
      p
    end

    def lesson_params
      params.permit :group_id, :date, :subject_id
    end

    def save_lesson(lesson)
      respond_with_existing_lesson unless lesson.save
    rescue ActiveRecord::RecordNotUnique
      respond_with_existing_lesson
    end

    def respond_with_existing_lesson
      lesson = Lesson.find_by lesson_params
      return unless lesson

      if @api_version == 2
        respond_with(lesson, status: :ok, meta: { timestamp: Time.zone.now }, serializer: LessonSerializerUuid)
      else
        respond_with(lesson, status: :ok, meta: { timestamp: Time.zone.now })
      end
    end
  end
end
