# frozen_string_literal: true

class StudentLessonsController < ApplicationController
  def show
    @lesson = lesson_from_param
    @student = Student.find params[:id]
    authorize @lesson, :show?
    @grades = @student.current_grades_for_lesson_including_ungraded_skills params[:lesson_id]
    @absence = @lesson.absences.map(&:student_id).include? @student.id
  end

  def update
    lesson = Lesson.find(params[:lesson_id])
    authorize lesson, :create?
    perform_grading
    notice_and_redirect I18n.t(:student_graded), lesson_path(lesson)
  end

  private

  def perform_grading
    student = Student.find params.require(:id)
    student.grade_lesson params.require(:lesson_id), generate_grades_from_params(student)

    mark_student_absence student
  end

  def student_absent?
    absence_param = params.require(:student).permit(:absences)[:absences]
    ActiveRecord::Type::Boolean.new.cast(absence_param)
  end

  def mark_student_absence(student)
    lesson = Lesson.includes(:absences).find params[:lesson_id]
    if student_absent?
      lesson.mark_student_as_absent student
    else
      lesson.mark_student_as_present student
    end
  end

  def generate_grades_from_params(student)
    filled_grades_attributes.map do |g|
      new_grade = Grade.new(id: g[:id], student: student, lesson_id: params[:lesson_id])
      new_grade.grade_descriptor = GradeDescriptor.find(g[:grade_descriptor_id])
      new_grade
    end
  end

  def filled_grades_attributes
    grades_attributes.select { |g| g['grade_descriptor_id'].present? || g['id'].present? }
  end

  def grades_attributes
    params.require(:student).permit(grades_attributes: %i[id skill grade_descriptor_id])[:grades_attributes].values
  end

  def lesson_from_param
    Lesson.includes(subject: [{ skills: [:grade_descriptors] }]).find params[:lesson_id]
  end
end
