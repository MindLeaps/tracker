# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def update?
    (user.global_administrator? && higher_global_role_level?(user, record)) || user.id == record.id
  end

  def show?
    user.global_administrator? || user.id == record.id
  end

  private

  def higher_global_role_level?(user1, user2)
    Role.max_role_level(user1.global_roles) > Role.max_role_level(user2.global_roles)
  end
end
