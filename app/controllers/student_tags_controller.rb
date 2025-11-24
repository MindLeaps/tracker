class StudentTagsController < HtmlController
  include Pagy::Method

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

  def new
    authorize Tag
    @tag = Tag.new
    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def edit
    @tag = Tag.find params.require(:id)
    authorize @tag
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

  def update
    @tag = Tag.find params.require(:id)
    authorize @tag

    if @tag.update tag_params
      success title: t(:tag_updated), text: t(:tag_updated_text, tag: @tag.tag_name)
      redirect_to student_tag_path(@tag)
    else
      failure title: t(:tag_invalid), text: t(:fix_form_errors)
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @tag = Tag.find params.require(:id)
    authorize @tag

    if @tag.can_delete?
      return unless @tag.destroy

      success title: t(:tag_deleted), text: t(:tag_deleted_text, tag_name: @tag.tag_name)
      redirect_to student_tags_path
    else
      failure title: t(:unable_to_delete_tag), text: t(:tag_not_deleted_because_students)
      redirect_to request.referer || student_tag_path(@tag)
    end
  end

  private

  def tag_params
    permitted = params.require(:tag).permit(:tag_name, :organization_id, :shared, shared_organization_ids: [])
    permitted[:shared_organization_ids] ||= []
    permitted[:shared_organization_ids] = permitted[:shared_organization_ids].compact_blank

    permitted
  end
end
