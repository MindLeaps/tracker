class ChaptersController < HtmlController
  include Pagy::Backend

  has_scope :exclude_deleted, type: :boolean, default: true
  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }
  has_scope :search, only: [:index]

  def index
    authorize Chapter
    @pagy, @chapters = pagy apply_scopes(policy_scope(ChapterSummary.includes(:organization), policy_scope_class: ChapterPolicy::Scope))
  end

  def show
    @chapter = Chapter.find params.require :id
    authorize @chapter
    @pagy, @groups = pagy apply_scopes(GroupSummary.includes(:chapter).where(chapter_id: @chapter.id))
  end

  def new
    authorize Chapter
    @chapter = Chapter.new
    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def edit
    @chapter = Chapter.find params.require :id
    authorize @chapter
  end

  def create
    @chapter = Chapter.new chapter_params
    authorize @chapter
    if @chapter.save
      success(title: t(:chapter_added), text: t(:chapter_added_text, chapter: @chapter.chapter_name))
      return redirect_to chapters_url
    end
    handle_turbo_failure_responses({ title: t(:chapter_invalid), text: t(:fix_form_errors) })
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

  def destroy
    @chapter = Chapter.find params.require :id
    authorize @chapter
    return unless @chapter.delete_chapter_and_dependents

    success(title: t(:chapter_deleted), text: t(:chapter_deleted_text, chapter: @chapter.chapter_name), button_path: undelete_chapter_path, button_method: :post, button_text: t(:undo))
    redirect_to request.referer || @chapter.path
  end

  def undelete
    @chapter = Chapter.find params.require :id
    authorize @chapter
    return unless @chapter.restore_chapter_and_dependents

    success(title: t(:chapter_restored), text: t(:chapter_restored_text, chapter: @chapter.chapter_name))
    redirect_to chapter_path
  end

  private

  def chapter_params
    params.require(:chapter).permit :chapter_name, :organization_id, :mlid
  end
end
