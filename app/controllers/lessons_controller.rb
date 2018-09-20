# frozen_string_literal: true

class LessonsController < ApplicationController
  include Pagy::Backend
  has_scope :exclude_deleted, type: :boolean, default: true
  has_scope :order, type: :hash

  def index
    authorize Lesson
    @pagy, @lessons = pagy apply_scopes(policy_scope(Lesson.includes(:subject, :group)))
    @lesson = Lesson.new
  end

  def show
    @lesson = Lesson.includes(:group, :subject).find(params[:id])
    authorize @lesson
    @pagy, @student_lesson_summaries = pagy apply_scopes(StudentLessonSummary.where(lesson_id: @lesson.id))
  end

  def new
    authorize Lesson
    @lesson = Lesson.new
  end

  def create
    @lesson = Lesson.new params.require(:lesson).permit :group_id, :date, :subject_id
    authorize @lesson
    return notice_and_redirect(t(:lesson_created), lessons_url) if @lesson.save

    render :index
  end
end
