# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action do
    @lessons = policy_scope Lesson.includes(:subject, :group).all
  end

  def index
    authorize Lesson
    @lesson = Lesson.new
  end

  def show
    @lesson = Lesson.includes(:absences, :group, :subject).find(params[:id])
    authorize @lesson
    @students = @lesson.group.students.exclude_deleted
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
