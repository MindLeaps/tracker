class MembershipPolicy < ApplicationPolicy
  def update?
    @user.global_administrator? || @user.is_admin_of?(@record.org)
  end

  def destroy?
    update? && @record.user.role_level_in(@record.org) != @user.role_level_in(@record.org)
  end

  def update_global_role?
    @user.global_administrator? && target_user_ranks_lower? && target_role_not_above_own_role?
  end

  def revoke_global_role?
    update_global_role? && target_user_global_level != @user.global_role.level
  end

  private

  def target_user_global_level
    @record.user.global_role.try(:level) || Role::MINIMAL_ROLE_LEVEL
  end

  def membership_role_level
    Role::ROLE_LEVELS[@record.role] || Role::MINIMAL_ROLE_LEVEL
  end

  def target_user_ranks_lower?
    target_user_global_level < @user.global_role.level
  end

  def target_role_not_above_own_role?
    membership_role_level <= @user.global_role.level
  end
end
