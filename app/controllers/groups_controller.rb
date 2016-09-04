class GroupsController < ApplicationController
  before_action do
    @groups = Group.all
  end

  def index
    @group = Group.new
  end

  def create
    @group = Group.new(params.require(:group).permit(:group_name, :chapter_id))
    return redirect_to groups_url if @group.save
    render :index
  end

  def show
    @group = Group.find params[:id]
  end
end
