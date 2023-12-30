# frozen_string_literal: true

class ChaptersController < HtmlController
  include Pagy::Backend
  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }
  has_scope :search, only: [:index]

  def index
    authorize Chapter
    @pagy, @chapters = pagy apply_scopes(policy_scope(ChapterSummary.includes(:organization), policy_scope_class: ChapterPolicy::Scope))
  end

  def new
    authorize Chapter
    @chapter = Chapter.new
  end

  def create
    @chapter = Chapter.new chapter_params
    authorize @chapter
    @chapter.mlid = @chapter.mlid&.upcase
    if @chapter.save
      success(title: t(:chapter_added), text: t(:chapter_added_text, chapter: @chapter.chapter_name))
      return redirect_to chapters_url
    end
    failure(title: t(:chapter_invalid), text: t(:fix_form_errors))
    render :new, status: :unprocessable_entity
  end

  def show
    @chapter = Chapter.find params.require :id
    authorize @chapter
    @pagy, @groups = pagy apply_scopes(GroupSummary.includes(:chapter).where(chapter_id: @chapter.id))
  end

  def edit
    @chapter = Chapter.find params.require :id
    authorize @chapter
  end

  def update
    @chapter = Chapter.includes(:organization).find params.require :id
    authorize @chapter
    if @chapter.update chapter_params
      success title: t(:chapter_updated), text: t(:chapter_name_updated, name: @chapter.chapter_name)
      return redirect_to(flash[:redirect] || chapter_url)
    end
    failure title: t(:chapter_invalid), text: t(:fix_form_errors)
    render :edit, status: :unprocessable_entity
  end

  private

  def chapter_params
    params.require(:chapter).permit :chapter_name, :organization_id, :mlid
  end
end
