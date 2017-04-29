# frozen_string_literal: true
class GroupsController < ApplicationController
  has_scope :exclude_deleted, type: :boolean, default: true

  before_action do
    @groups = apply_scopes Group.includes(:chapter, :students)
  end

  def index
    @group = Group.new
  end

  def create
    @group = Group.new group_params
    return notice_and_redirect t(:group_created, group: @group.group_name), groups_url if @group.save
    render :index
  end

  def show
    @group = Group.includes(:chapter).find params[:id]
    @students = @group.students.exclude_deleted.includes :profile_image
  end

  def edit
    @group = Group.find params.require :id
  end

  def update
    @group = Group.find params.require :id
    return notice_and_redirect t(:group_updated, group: @group.group_name), group_url if @group.update_attributes group_params
    render :edit, status: 422
  end

  def destroy
    group = Group.find params.require :id
    group.deleted_at = Time.zone.now
    undo_notice_and_redirect t(:group_deleted, group: group.group_name), undelete_group_path, groups_path if group.save
  end

  def undelete
    group = Group.find params.require :id
    group.deleted_at = nil
    notice_and_redirect t(:group_restored, group: group.group_name), groups_path if group.save
  end

  private

  def group_params
    params.require(:group).permit :group_name, :chapter_id
  end
end
