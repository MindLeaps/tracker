module Api
  class StudentsController < ApiController
    def index
      if not params[:group_id]
        @students = Student.all
      else
        @students = Student.where group_id: params[:group_id]
      end
      respond_with @students
    end

    def show
      @student = Student.find params[:id]
      respond_with @student
    end
  end
end
