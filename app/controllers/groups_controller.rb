class GroupsController < ApplicationController
  before_action do
    @groups = Group.all
  end

  def index
    @group = Group.new
  end

  def create
    @group = Group.new(params.require(:group).permit(:group_name, :chapter_id))
    @group.save
    redirect_to groups_url
  end

  def show
    @group = Group.find params[:id]
  end
end
