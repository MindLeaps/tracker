# frozen_string_literal: true

class UsersController < ApplicationController
  include Pagy::Backend
  before_action do
    @pagy, @users = pagy policy_scope(User.all)
  end

  def index
    authorize User
  end

  def new
    authorize User
    @user = User.new
  end

  def create
    @user = User.new params.require(:user).permit(:email)
    authorize @user
    return notice_and_redirect(t(:user_added, email: params[:user][:email]), users_url) if @user.save
    render :index
  end

  def show
    @user = User.find params[:id]
    @membership = Membership.new user: @user
    authorize @user
  end
end
