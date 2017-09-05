# frozen_string_literal: true

class MembershipsController < ApplicationController
  def update
    @user = User.find params.require :user_id
    role = params.require(:role).to_sym
    org = Organization.find params.require :id

    return redirect_to @user if RoleService.update_local_role @user, role, org
    render 'users/show', status: :bad_request
  end

  def destroy
    user = User.find params.require :user_id
    org = Organization.find params.require :id
    RoleService.revoke_local_role user, org
    redirect_to user
  end
end
