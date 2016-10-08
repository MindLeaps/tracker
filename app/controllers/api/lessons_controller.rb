module Api
  class LessonsController < ApiController
    def index
      respond_with Lesson.all
    end

    def show
      respond_with Lesson.find params[:id]
    end

    def create
      @lesson = Lesson.new params.permit :group_id, :date, :subject_id
      @lesson.save
      respond_with @lesson
    end
  end
end
