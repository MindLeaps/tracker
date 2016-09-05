class UsersController < ApplicationController
  before_action do
    @users = User.all
  end

  def index
    @user = User.new
  end

  def create
    @user = User.new params.require(:user).permit(:email)
    return redirect_to users_url if @user.save
    render :index
  end
end
