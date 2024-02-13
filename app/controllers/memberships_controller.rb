# frozen_string_literal: true

class MembershipsController < HtmlController
  def update
    @user = User.find params.require :user_id
    role = params.require(:membership).require(:role).to_sym
    org = Organization.find params.require :id
    authorize Membership.new(user: @user, role:, org:)

    return redirect_to @user if RoleService.update_local_role @user, role, org

    render 'users/show', status: :bad_request
  end

  def destroy
    user = User.find params.require :user_id
    org = Organization.find params.require :id
    authorize Membership.new(user:, org:)
    RoleService.revoke_local_role user, org
    redirect_to user
  end

  def update_global_role
    @user = User.find params.require :user_id
    role = params.require(:role).to_sym
    authorize Membership.new(user: @user, role:)

    if RoleService.update_global_role @user, role
      success title: t(:role_updated), text: t(:global_role_updated_text, email: @user.email, role: params.require(:role))
      return redirect_to @user
    end

    render 'users/show', status: :bad_request
  end

  def revoke_global_role
    @user = User.find params.require :user_id
    authorize Membership.new(user: @user)
    if RoleService.revoke_global_role @user
      success title: t(:role_updated), text: t(:global_role_revoked, email: @user.email)
      redirect_to @user
    else
      render 'users/show', status: :bad_request
    end
  end
end
