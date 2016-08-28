module Api
  class StudentsController < ApiController
    def index
      @students = if params[:group_id]
                    Student.where group_id: params[:group_id]
                  else
                    Student.all
                  end
      respond_with @students
    end

    def show
      @student = Student.find params[:id]
      respond_with @student
    end
  end
end
