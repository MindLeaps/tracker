# frozen_string_literal: true

class GroupsController < HtmlController
  include Pagy::Backend
  has_scope :exclude_deleted, type: :boolean, default: true
  has_scope :table_order, type: :hash, default: { key: :created_at, order: :desc }
  has_scope :search, only: [:show, :index]

  def index
    authorize Group
    @group = Group.new
    @pagy, @groups = pagy policy_scope(apply_scopes(GroupSummary.includes(chapter: [:organization])), policy_scope_class: GroupPolicy::Scope)
  end

  def new
    authorize Group
    @group = populate_new_group
    respond_to do |format|
      format.turbo_stream
      format.html { render :new }
    end
  end

  def create
    @group = Group.new group_params
    if @group.valid? && @group.save
      authorize @group
      success(title: t(:group_added), text: t(:group_with_name_added, group: @group.group_name))
      return redirect_to groups_path
    end
    skip_authorization
    handle_turbo_failure_responses({ title: t(:group_invalid), text: t(:fix_form_errors) })
  end

  def show
    @group = Group.includes(:chapter).find params[:id]
    authorize @group
    @pagy, @student_rows = pagy apply_scopes(StudentTableRow.where(group_id: @group.id).includes(:tags, :group))
    @student_table_component = TableComponents::Table.new(pagy: @pagy, rows: @student_rows, row_component: TableComponents::StudentRow)
  end

  def edit
    @group = Group.find params.require :id
    authorize @group
  end

  def update
    @group = Group.find params.require :id
    if @group.valid? && @group.update(group_params)
      authorize @group
      success title: t(:group_updated), text: t(:group_name_updated, group: @group.group_name)
      return redirect_to(flash[:redirect] || group_path(@group))
    end
    skip_authorization

    failure title: t(:group_invalid), text: t(:fix_form_errors)
    render :edit, status: :unprocessable_entity
  end

  def destroy
    group = Group.find params.require :id
    authorize group
    group.deleted_at = Time.zone.now
    return unless group.save

    success(title: t(:group_deleted), text: t(:group_deleted_text, group: group.group_name), button_path: undelete_group_path, button_method: :post, button_text: t(:undo))
    redirect_to request.referer || group.path
  end

  def undelete
    group = Group.find params.require :id
    authorize group
    group.deleted_at = nil
    return unless group.save

    success(title: t(:group_restored), text: t(:group_restored_text, group: group.group_name))
    redirect_to group_path
  end

  private

  def group_params
    params.require(:group).permit :group_name, :mlid, :chapter_id
  end

  def populate_new_group
    group = Group.new
    group.chapter = Chapter.find(new_params[:chapter_id]) if new_params[:chapter_id]
    group
  end

  def new_params
    params.permit :chapter_id
  end
end
