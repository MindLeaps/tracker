# frozen_string_literal: true
class GroupsController < ApplicationController
  has_scope :exclude_deleted, type: :boolean, default: true

  before_action do
    @groups = Group.includes(:chapter, :students).all
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
    @students = @group.students.exclude_deleted
  end

  def edit
    @group = Group.find params.require :id
  end

  def update
    @group = Group.find params.require :id
    return notice_and_redirect t(:group_updated, group: @group.group_name), group_url if @group.update_attributes group_params
    render :edit, status: 422
  end

  private

  def group_params
    params.require(:group).permit :group_name, :chapter_id
  end
end
