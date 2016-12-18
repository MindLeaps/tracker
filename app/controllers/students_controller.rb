# frozen_string_literal: true
class StudentsController < ApplicationController
  has_scope :exclude_deleted, type: :boolean, default: true

  def index
    @students = apply_scopes policy_scope(Student)
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new student_params
    return link_notice_and_redirect t(:student_created, name: @student.proper_name), new_student_path, 'Create another', @student if @student.save
    render :new
  end

  def show
    @student = Student.find params[:id]
  end

  def edit
    @student = Student.find params[:id]
  end

  def update
    @student = Student.find params[:id]
    return redirect_to @student if @student.update_attributes student_params

    render :edit
  end

  def destroy
    @student = Student.find params.require :id
    @student.deleted_at = Time.zone.now

    return undo_notice_and_redirect t(:student_deleted, name: @student.proper_name), undelete_student_path, students_path if @student.save
  end

  def undelete
    @student = Student.find params.require :id
    @student.deleted_at = nil

    return notice_and_redirect t(:student_restored, name: @student.proper_name), students_path if @student.save
  end

  def grades
    @student = Student.find params[:id]
    lesson = Lesson.find params[:lesson_id]
    @grades = @student.current_grades_for_lesson_including_ungraded_skills params[:lesson_id]
    @absence = lesson.absences.map(&:student_id).include? @student.id
  end

  def grade
    student = Student.find params[:id]
    lesson = Lesson.find params[:lesson_id]
    grades = generate_grades_from_params student
    student.grade_lesson params[:lesson_id], grades
    mark_student_absence lesson, student, absence_param
    notice_and_redirect 'Student successfully graded.', grades_lesson_student_path
  end

  private

  def student_params
    params.require(:student).permit(*Student.permitted_params)
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

  def absence_param
    params.require(:student).permit(:absences)[:absences]
  end

  def mark_student_absence(lesson, student, absence)
    if absence == '1'
      lesson.mark_student_as_absent student
    elsif absence == '0'
      lesson.mark_student_as_present student
    end
  end
end
