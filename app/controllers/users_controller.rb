class UsersController < ApplicationController
  before_action do
    @users = User.all
  end

  def index
    authorize User
    @user = User.new
  end

  def create
    authorize User
    @user = User.new params.require(:user).permit(:email)
    return redirect_to users_url if @user.save
    render :index
  end

  def show
    @user = User.find params[:id]
  end
end
