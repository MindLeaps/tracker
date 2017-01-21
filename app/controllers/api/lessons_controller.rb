# frozen_string_literal: true
module Api
  class LessonsController < ApiController
    has_scope :after_timestamp
    has_scope :by_group, as: :group_id
    has_scope :by_subject, as: :subject_id

    def index
      @lessons = apply_scopes(Lesson).all
      respond_with @lessons, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def show
      @lesson = Lesson.find params.require :id
      respond_with @lesson, include: included_params, meta: { timestamp: Time.zone.now }
    end

    def create
      lesson = Lesson.new lesson_params

      respond_with_existing_lesson unless lesson.save

      respond_with lesson, meta: { timestamp: Time.zone.now } unless performed?
    end

    private

    def respond_with_existing_lesson
      lesson = Lesson.find_by lesson_params
      respond_with(lesson, status: :ok, meta: { timestamp: Time.zone.now }) if lesson
    end

    def lesson_params
      params.permit :group_id, :date, :subject_id
    end
  end
end
