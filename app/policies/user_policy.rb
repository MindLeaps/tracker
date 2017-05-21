# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?
    if user.administrator?
      return true if user.current_role_level > record.current_role_level
      return user.id == record.id
    end
    false
  end

  def show?
    user.is_super_admin? || user.is_admin? || user.id == record.id
  end
end
