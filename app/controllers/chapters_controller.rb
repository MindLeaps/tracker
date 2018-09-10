# frozen_string_literal: true

class ChaptersController < ApplicationController
  include Pagy::Backend
  def index
    authorize Chapter
    @pagy, @chapters = pagy policy_scope(Chapter.includes(:organization, groups: [:students]))
  end

  def new
    authorize Chapter
    @chapter = Chapter.new
  end

  def create
    @chapter = Chapter.new chapter_params
    authorize @chapter
    return notice_and_redirect t(:chapter_created, chapter: @chapter.chapter_name), chapters_url if @chapter.save
    @chapters = Chapter.includes(:organization, groups: [:students]).all
    render :new
  end

  def show
    @chapter = Chapter.find params.require :id
    authorize @chapter
    @pagy, @groups = pagy @chapter.groups
  end

  def edit
    @chapter = Chapter.find params.require :id
    authorize @chapter
  end

  def update
    @chapter = Chapter.includes(:organization).find params.require :id
    authorize @chapter
    return notice_and_redirect t(:chapter_updated, chapter: @chapter.chapter_name), chapter_url if @chapter.update chapter_params
    render :edit, status: :unprocessable_entity
  end

  private

  def chapter_params
    params.require(:chapter).permit :chapter_name, :organization_id
  end
end
