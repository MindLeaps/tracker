# frozen_string_literal: true

class StudentTagsController < HtmlController
  include Pagy::Backend
  has_scope :table_order, only: [:index, :show], type: :hash
  has_scope :search, only: [:index, :show]

  def index
    authorize Tag
    @pagy, @tags = pagy apply_scopes(policy_scope(StudentTagTableRow.includes(:organization), policy_scope_class: TagPolicy::Scope))
  end

  def show
    @tag = Tag.find params.require(:id)
    authorize @tag
    @pagy, @students = pagy apply_scopes(policy_scope(StudentTableRow.includes(:tags,
                                                                               { group: { chapter: :organization } }).joins("INNER JOIN student_tags ON student_id = student_table_rows.id AND tag_id = '#{@tag.id}'")))
  end

  def edit
    @tag = Tag.find params.require(:id)
    authorize @tag
  end

  def update
    @tag = Tag.find params.require(:id)
    authorize @tag
    return redirect_to student_tag_path(@tag) if @tag.update tag_params

    render :edit
  end

  def new
    authorize Tag
    @tag = Tag.new
    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def create
    @tag = Tag.new tag_params
    authorize @tag
    if @tag.save
      success title: t(:tag_added), text: t(:tag_with_name_added, name: @tag.tag_name)
      return redirect_to student_tags_path
    end
    handle_turbo_failure_responses({ title: t(:invalid_tag), text: t(:fix_form_errors) })
  end

  private

  def tag_params
    params.require(:tag).permit(:tag_name, :organization_id, :shared)
  end
end
