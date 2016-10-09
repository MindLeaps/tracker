# frozen_string_literal: true
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
    @user.add_role :user
    return redirect_to users_url if @user.save
    render :index
  end

  def show
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]
    @user.update_role params.require(:user)[:roles]
    redirect_to @user
  end
end
