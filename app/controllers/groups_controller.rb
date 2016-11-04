# frozen_string_literal: true
class GroupsController < ApplicationController
  before_action do
    @groups = Group.all
  end

  def index
    @group = Group.new
  end

  def create
    @group = Group.new group_params
    return redirect_to groups_url if @group.save
    render :index
  end

  def show
    @group = Group.find params[:id]
  end

  def edit
    @group = Group.find params.require :id
  end

  def update
    @group = Group.find params.require :id
    return notice_and_redirect t(:group_updated, group: @group.group_name), group_url if @group.update_attributes group_params
    render action: :edit, status: 422
  end

  private

  def group_params
    params.require(:group).permit :group_name, :chapter_id
  end
end
