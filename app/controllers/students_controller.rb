class StudentsController < ApplicationController
  def new
	@student = Student.new
  end

  def create
  	@student = Student.new(params.require(:student).permit(:first_name, :last_name, :dob))
  	if @student.save
  		redirect_to :new_student
  	else
  		render :new
  	end
  end
end
