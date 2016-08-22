module Api
  class StudentsController < ApiController
    def index
      @students = Student.all
      respond_with @students
    end

    def show
      @student = Student.find params[:id]
      respond_with @student
    end
  end
end
