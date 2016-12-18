# frozen_string_literal: true
class StudentLessonsController < ApplicationController
  def show
    @student = Student.find params[:id]
    @lesson = Lesson.find params[:lesson_id]
    @grades = @student.current_grades_for_lesson_including_ungraded_skills params[:lesson_id]
    @absence = @lesson.absences.map(&:student_id).include? @student.id
  end

  def update
    student = Student.find params[:id]
    student.grade_lesson params[:lesson_id], generate_grades_from_params(student)

    mark_student_absence student
    notice_and_redirect I18n.t(:student_graded), lesson_student_path
  end

  private

  def absence
    params.require(:student).permit(:absences)[:absences]
  end

  def mark_student_absence(student)
    lesson = Lesson.find params[:lesson_id]
    if absence == '1'
      lesson.mark_student_as_absent student
    elsif absence == '0'
      lesson.mark_student_as_present student
    end
  end

  def generate_grades_from_params(student)
    filled_grades_attributes
      .map { |g| Grade.new(id: g[:id], student: student, lesson_id: params[:lesson_id], grade_descriptor_id: g[:grade_descriptor_id]) }
  end

  def filled_grades_attributes
    grades_attributes.select { |g| !g['grade_descriptor_id'].empty? || !g['id'].blank? }
  end

  def grades_attributes
    params.require(:student).permit(grades_attributes: [:id, :skill, :grade_descriptor_id])[:grades_attributes].values
  end
end
