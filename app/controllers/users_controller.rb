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

  def update
    @user = User.find params.require :id
    org_role = parse_org_role(params.require(:user).require(:roles))

    return redirect_to @user if RoleService.update_local_role @user, org_role[:role], org_role[:org]
    render :show, status: :bad_request
  end

  private

  def parse_org_role(org_role)
    org_role.each do |org_id, role_name|
      org = Organization.find org_id
      return { org: org, role: role_name }
    end
  end
end
