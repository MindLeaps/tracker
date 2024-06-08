module Api
  class LessonsController < ApiController
    has_scope :after_timestamp
    has_scope :by_group, as: :group_id
    has_scope :by_subject, as: :subject_id

    def index
      @lessons = apply_scopes(@api_version == 2 ? policy_scope(Lesson) : Lesson).all

      authorize Lesson
      respond_with @lessons, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @lesson = Lesson.find params.require :id
      respond_with @lesson, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def create
      lesson = Lesson.new lesson_params
      authorize lesson
      save_lesson lesson

      return if performed?

      respond_with lesson, meta: { timestamp: Time.zone.now }
    end

    private

    def lesson_params
      params.permit :id, :group_id, :date, :subject_id
    end

    def save_lesson(lesson)
      respond_with_existing_lesson unless lesson.save
    rescue ActiveRecord::RecordNotUnique
      respond_with_existing_lesson
    end

    def respond_with_existing_lesson
      lesson = Lesson.find_by lesson_params
      return unless lesson

      respond_with(lesson, status: :ok, meta: { timestamp: Time.zone.now })
    end
  end
end
