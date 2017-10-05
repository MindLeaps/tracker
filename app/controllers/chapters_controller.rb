# frozen_string_literal: true

class ChaptersController < ApplicationController
  def index
    authorize Chapter
    @chapters = policy_scope Chapter.includes(:organization, groups: [:students])
    @chapter = Chapter.new
  end

  def create
    @chapter = Chapter.new chapter_params
    authorize @chapter
    return notice_and_redirect t(:chapter_created, chapter: @chapter.chapter_name), chapters_url if @chapter.save
    @chapters = Chapter.includes(:organization, groups: [:students]).all
    render :index
  end

  def show
    @chapter = Chapter.includes(:organization).find params.require :id
    authorize @chapter
  end

  def edit
    @chapter = Chapter.find params.require :id
    authorize @chapter
  end

  def update
    @chapter = Chapter.includes(:organization).find params.require :id
    authorize @chapter
    return notice_and_redirect t(:chapter_updated, chapter: @chapter.chapter_name), chapter_url if @chapter.update_attributes chapter_params
    render :edit, status: 422
  end

  private

  def chapter_params
    params.require(:chapter).permit :chapter_name, :organization_id
  end
end
