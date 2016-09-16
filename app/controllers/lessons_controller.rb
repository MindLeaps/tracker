class LessonsController < ApplicationController
  before_action do
    @lessons = Lesson.all
  end

  def index
    @lesson = Lesson.new
  end

  def create
    @lesson = Lesson.new params.require(:lesson).permit :group_id, :date
    return notice_and_redirect('Lesson successfully created', lessons_url) if @lesson.save
    render :index
  end
end
