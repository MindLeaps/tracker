class StudentsController < ApplicationController
  before_action do
    @students = Student.all
  end

  def index
    @student = Student.new
  end

  def create
    @student = Student.new student_params
    @student.save
    render :index
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

  private

  def student_params
    params.require(:student).permit(:first_name, :last_name, :dob, :estimated_dob, :group_id)
  end
end
