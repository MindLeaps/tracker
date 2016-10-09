# frozen_string_literal: true
class ChaptersController < ApplicationController
  before_action do
    @chapters = Chapter.all
  end

  def index
    @chapter = Chapter.new
  end

  def create
    @chapter = Chapter.new(params.require(:chapter).permit(:chapter_name, :organization_id))
    return redirect_to chapters_url if @chapter.save
    render :index
  end

  def show
    @chapter = Chapter.find params[:id]
  end
end
