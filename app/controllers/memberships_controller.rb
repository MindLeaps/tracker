# frozen_string_literal: true

class MembershipsController < HtmlController
  def update
    @user = User.find params.require :user_id
    role = params.require(:role).to_sym
    org = Organization.find params.require :id
    authorize Membership.new(user: @user, role: role, org: org)

    return redirect_to @user if RoleService.update_local_role @user, role, org

    render 'users/show', status: :bad_request
  end

  def destroy
    user = User.find params.require :user_id
    org = Organization.find params.require :id
    authorize Membership.new(user: user, org: org)
    RoleService.revoke_local_role user, org
    redirect_to user
  end

  def update_global_role
    @user = User.find params.require :user_id
    role = params.require(:role).to_sym
    authorize Membership.new(user: @user, role: role)

    return redirect_to @user if RoleService.update_global_role @user, role

    render 'users/show', status: :bad_request
  end

  def revoke_global_role
    @user = User.find params.require :user_id
    authorize Membership.new(user: @user)
    RoleService.revoke_global_role @user
    redirect_to @user
  end
end
