class GroupMergesController < HtmlController
  skip_after_action :verify_policy_scoped

  def new
    authorize Group, :merge?
    @destination_group = active_groups.find_by(id: params[:destination_group_id])
    set_group_options
  end

  def preview
    @source_group = active_groups.find(group_merge_params.require(:source_group_id))
    @destination_group = active_groups.find(group_merge_params.require(:destination_group_id))
    authorize @destination_group, :merge?
    @preview = GroupMergePreview.new(source_group: @source_group, destination_group: @destination_group)
    set_group_options
  rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound
    authorize Group, :merge?
    set_group_options
    failure_now(title: 'Invalid group merge', text: 'Choose an active source group and destination group.')
    render :new, status: :unprocessable_content
  end

  def create
    @source_group = active_groups.find(group_merge_params.require(:source_group_id))
    @destination_group = active_groups.find(group_merge_params.require(:destination_group_id))
    authorize @destination_group, :merge?

    merge = GroupMerge.new(source_group: @source_group, destination_group: @destination_group)
    merge.merge!

    success(title: 'Groups merged', text: "#{@source_group.group_name} was merged into #{@destination_group.group_name}. Analytics and reports now reflect the merged group.")
    redirect_to group_path(@destination_group)
  rescue ActionController::ParameterMissing, ActiveRecord::RecordNotFound, ActiveRecord::RecordInvalid
    authorize Group, :merge? unless pundit_policy_authorized?
    set_group_options
    failure_now(title: 'Invalid group merge', text: 'Choose two active groups in the same chapter.')
    render :new, status: :unprocessable_content
  end

  private

  def pundit_policy_authorized?
    @_pundit_policy_authorized
  end

  def group_merge_params
    params.require(:group_merge).permit(:source_group_id, :destination_group_id)
  end

  def set_group_options
    @destination_groups = active_groups
    @source_groups = source_groups
  end

  def source_groups
    return active_groups unless @destination_group

    active_groups.where(chapter_id: @destination_group.chapter_id).where.not(id: @destination_group.id)
  end

  def active_groups
    @active_groups ||= policy_scope(Group).includes(chapter: :organization).where(deleted_at: nil).order(:group_name)
  end
end
