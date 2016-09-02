class ChaptersController < ApplicationController
  before_action do
    @chapters = Chapter.all
  end

  def index
    @chapter = Chapter.new
  end

  def create
    @chapter = Chapter.new(params.require(:chapter).permit(:chapter_name))
    @chapter.save
    redirect_to chapters_url
  end
end
