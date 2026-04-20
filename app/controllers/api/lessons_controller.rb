module Api
  class LessonsController < ApiController
    has_scope :after_timestamp
    has_scope :by_group, as: :group_id
    has_scope :by_subject, as: :subject_id

    def index
      @lessons = apply_scopes(versioned_scope(Lesson, policy_versions: [2])).all

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
      respond_with_existing_or_conflicting_lesson(lesson) unless lesson.save
    rescue ActiveRecord::RecordNotUnique
      respond_with_existing_or_conflicting_lesson lesson
    end

    def respond_with_existing_or_conflicting_lesson(lesson)
      existing_lesson = Lesson.find_by id: lesson.id
      return respond_with(existing_lesson, status: :ok, meta: { timestamp: Time.zone.now }) if existing_lesson

      duplicate_params = lesson_params.slice(:group_id, :date, :subject_id)
      return unless duplicate_params.values.all?(&:present?)

      conflicting_lesson = Lesson.find_by duplicate_params
      respond_with(conflicting_lesson, status: :conflict, meta: { timestamp: Time.zone.now }) if conflicting_lesson
    end
  end
end
