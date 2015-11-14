class StudentsController < ApplicationController
  before_action do
    @students = Student.all
  end

  def index
    @student = Student.new
  end

  def create
    @student = Student.new(params.require(:student).permit(:first_name, :last_name, :dob))
    @student.save
    render :index
  end
end
