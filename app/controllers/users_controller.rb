# frozen_string_literal: true

class UsersController < ApplicationController
  include Pagy::Backend
  has_scope :table_order, type: :hash

  before_action do
    @pagy, @users = pagy apply_scopes(policy_scope(User.all))
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

  def create_api_token
    @user = User.find params.require(:id)
    authorize @user
    @user.authentication_tokens.destroy_all
    @token = Tiddle.create_and_return_token @user, request, expires_in: 1.hour
    render :show, status: :created
  end

  def show
    @user = User.find params[:id]
    @membership = Membership.new user: @user
    authorize @user
  end
end
