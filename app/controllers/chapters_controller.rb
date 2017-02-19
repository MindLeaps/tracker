# frozen_string_literal: true
class ChaptersController < ApplicationController
  def index
    @chapters = Chapter.includes(groups: [:students]).all
    @chapter = Chapter.new
  end

  def create
    @chapter = Chapter.new chapter_params
    return notice_and_redirect t(:chapter_created, chapter: @chapter.chapter_name), chapters_url if @chapter.save
    render :index
  end

  def show
    @chapter = Chapter.includes(:organization).find params.require :id
  end

  def edit
    @chapter = Chapter.find params.require :id
  end

  def update
    @chapter = Chapter.includes(:organization).find params.require :id
    return notice_and_redirect t(:chapter_updated, chapter: @chapter.chapter_name), chapter_url if @chapter.update_attributes chapter_params
    render :edit, status: 422
  end

  private

  def chapter_params
    params.require(:chapter).permit :chapter_name, :organization_id
  end
end
