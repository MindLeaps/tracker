class LessonsController < ApplicationController
  before_action do
    @lessons = Lesson.all
  end

  def index
    @lesson = Lesson.new
  end

  def create
    @lesson = Lesson.new params.require(:lesson).permit :group_id, :date
    return redirect_to lessons_url if @lesson.save
    render :index
  end
end
