# frozen_string_literal: true

class LessonsController < ApplicationController
  include Pagy::Backend
  before_action do
    @pagy, @lessons = pagy policy_scope(Lesson.includes(:subject, :group))
  end

  def index
    authorize Lesson
    @lesson = Lesson.new
  end

  def show
    @lesson = Lesson.includes(:absences, :group, :subject).find(params[:id])
    authorize @lesson
    @pagy, @students = pagy @lesson.group.students.exclude_deleted
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
