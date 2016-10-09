# frozen_string_literal: true
class LessonsController < ApplicationController
  before_action do
    @lessons = Lesson.all
  end

  def index
    @lesson = Lesson.new
  end

  def show
    @lesson = Lesson.find params[:id]
  end

  def create
    @lesson = Lesson.new params.require(:lesson).permit :group_id, :date, :subject_id
    return notice_and_redirect(t(:lesson_created), lessons_url) if @lesson.save
    render :index
  end
end
