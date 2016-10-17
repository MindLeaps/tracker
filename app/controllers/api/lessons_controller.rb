# frozen_string_literal: true
module Api
  class LessonsController < ApiController
    def index
      @lessons = Lesson.all
      respond_with @lessons, meta: { timestamp: Time.zone.now }
    end

    def show
      @lesson = Lesson.find params.require :id
      respond_with @lesson, meta: { timestamp: Time.zone.now }
    end

    def create
      @lesson = Lesson.new params.permit :group_id, :date, :subject_id
      @lesson.save
      respond_with @lesson, meta: { timestamp: Time.zone.now }
    end
  end
end
