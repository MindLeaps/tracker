class StudentsController < ApplicationController
  before_action do
    @students = Student.all
  end

  def index
    @student = Student.new
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new student_params
    return redirect_to @student if @student.save
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

  private

  def student_params
    params.require(:student).permit(*Student.permitted_params)
  end
end
