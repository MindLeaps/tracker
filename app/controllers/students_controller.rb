class StudentsController < ApplicationController
  def index
    @students = policy_scope Student
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new student_params
    return notice_and_redirect t(:student_created, name: @student.proper_name), @student if @student.save
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

  def grades
    @student = Student.find params[:id]
    @grades = @student.grades_for_lesson params[:lesson_id]
  end

  def grade
    @student = Student.find params[:id]
    @lesson = Lesson.find params[:lesson_id]
    filled_grades = filled_grade_attributes permit_grades_params[:grades_attributes].values
    grades = filled_grades.map { |g| Grade.new(student: @student, lesson: @lesson, grade_descriptor_id: g[:grade_descriptor_id]) }
    @student.grade_lesson params[:lesson_id], grades
    notice_and_redirect 'Student successfully graded.', grades_lesson_student_path
  end

  private

  def student_params
    params.require(:student).permit(*Student.permitted_params)
  end

  def filled_grade_attributes(grade_attributes)
    grade_attributes.select { |g| !g['grade_descriptor_id'].empty? }
  end

  def permit_grades_params
    params.require(:student).permit grades_attributes: [:id, :skill, :grade_descriptor_id]
  end
end
