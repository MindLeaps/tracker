class UserPolicy < ApplicationPolicy
  def update?
    if user.is_super_admin?
      return user.id == record.id if record.is_super_admin?
      return true
    end
    if user.is_admin?
      return false if record.is_super_admin?
      return user.id == record.id if record.is_admin?
      return true
    end
    false
  end

  def show?
    user.is_super_admin? || user.is_admin? || user.id == record.id
  end
end
