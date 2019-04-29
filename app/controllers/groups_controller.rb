# frozen_string_literal: true

class GroupsController < ApplicationController
  include Pagy::Backend
  has_scope :exclude_deleted, type: :boolean, default: true
  has_scope :table_order, type: :hash
  has_scope :search, only: :show

  def index
    authorize Group
    @group = Group.new
    @pagy, @groups = pagy policy_scope(apply_scopes(GroupSummary), policy_scope_class: GroupPolicy::Scope)
  end

  def new
    authorize Group
    @group = Group.new
  end

  def create
    @group = Group.new group_params
    authorize @group
    return notice_and_redirect t(:group_created, group: @group.group_name), group_path(@group) if @group.save

    render :new
  end

  def show
    @group = Group.includes(:chapter).find params[:id]
    authorize @group
    @pagy, @students = pagy apply_scopes(@group.students.includes(:profile_image))
  end

  def edit
    @group = Group.find params.require :id
    authorize @group
  end

  def update
    @group = Group.find params.require :id
    authorize @group
    return notice_and_redirect t(:group_updated, group: @group.group_name), group_url if @group.update group_params

    render :edit, status: :unprocessable_entity
  end

  def destroy
    group = Group.find params.require :id
    authorize group
    group.deleted_at = Time.zone.now
    undo_notice_and_redirect t(:group_deleted, group: group.group_name), undelete_group_path, request.referer || groups_path if group.save
  end

  def undelete
    group = Group.find params.require :id
    authorize group
    group.deleted_at = nil
    notice_and_redirect t(:group_restored, group: group.group_name), request.referer || group_path(group) if group.save
  end

  private

  def group_params
    params.require(:group).permit :group_name, :chapter_id
  end
end
