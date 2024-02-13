# frozen_string_literal: true

class StudentLessonsController < HtmlController
  def show
    lesson = lesson_from_param
    authorize lesson, :show?
    @student_lesson = StudentLesson.new(student_id: params.require(:id), lesson:)
    @absent = lesson.absences.map(&:student_id).include? @student_lesson.student_id
    respond_to(&:turbo_stream)
  end

  def update
    lesson = Lesson.find params.require(:lesson_id)
    authorize lesson, :create?

    student_lesson = StudentLesson.new(student_id: params.require(:id), lesson:)
    student_lesson.perform_grading format_attributes, student_absent?

    success(title: t(:student_graded), text: t(:student_graded_text, student: student_lesson.student.proper_name))
    redirect_to lesson_path(lesson)
  end

  private

  def student_absent?
    absence_param = params.require(:student_lesson).permit(:absence)[:absence]
    ActiveRecord::Type::Boolean.new.cast(absence_param) || false
  end

  def grades_attributes
    params.require(:student_lesson).permit(grades_attributes: %i[skill_id grade_descriptor_id])[:grades_attributes].values
  end

  def format_attributes
    grades_attributes
      .select { |g| g['grade_descriptor_id'].present? }
      .reduce({}) { |acc, v| acc.merge(v['skill_id'].to_i => v['grade_descriptor_id'].to_i) }
  end

  def lesson_from_param
    Lesson.find params[:lesson_id]
  end
end
