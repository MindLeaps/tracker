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
    return redirect_to users_url if @user.save
    render :index
  end

  def show
    @user = User.find params[:id]
  end

  def update_global_role
    @user = User.find params.require :id
    new_role = params.require(:user).require(:role).to_sym

    return redirect_to @user if RoleService.update_global_role @user, new_role
    render :show, status: :bad_request
  end

  def revoke_global_role
    @user = User.find params.require :id
    RoleService.revoke_global_role @user
    redirect_to @user
  end
end
