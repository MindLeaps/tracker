# frozen_string_literal: true

class LessonsController < ApplicationController
  include Pagy::Backend
  has_scope :exclude_deleted, type: :boolean, default: true
  has_scope :table_order, type: :hash

  def index
    authorize Lesson
    @pagy, @lessons = pagy apply_scopes(policy_scope(Lesson.includes(:subject, :group)))
    @lesson = Lesson.new
  end

  def show
    @lesson = Lesson.includes(:group, :subject).find(params[:id])
    authorize @lesson
    @pagy, @student_lesson_summaries = pagy apply_scopes(StudentLessonSummary.where(lesson_id: @lesson.id))
    @students = @lesson.group.students
    @lesson_skill_summary = LessonSkillSummary.where(lesson_uid: @lesson.uid)
    @group_lessons_data = process_group_lesson_data(GroupLessonSummary.find_by(lesson_uid: @lesson.uid)&.around(31) || [], @lesson)
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

  private

  def process_group_lesson_data(data, current_lesson)
    {
      prev_lesson_url: get_prev_lesson_url(current_lesson, data),
      next_lesson_url: get_next_lesson_url(current_lesson, data),
      group_lessons: data.map do |l|
        h = l.as_json
        h[:lesson_url] = lesson_url l.lesson_id
        h
      end
    }
  end

  def get_prev_lesson_url(lesson, data)
    i = data.find_index { |e| e.lesson_uid == lesson.uid }
    i.present? && i.positive? ? lesson_url(data[i - 1].lesson_id, request.query_parameters) : nil
  end

  def get_next_lesson_url(lesson, data)
    i = data.find_index { |e| e.lesson_uid == lesson.uid }
    i.present? && i + 1 < data.size ? lesson_url(data[i + 1].lesson_id, request.query_parameters) : nil
  end
end
