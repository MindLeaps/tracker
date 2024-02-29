class UserPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.global_role? || users_in_same_org?
  end

  def create?
    user.global_administrator?
  end

  def create_api_token?
    user.id == record.id
  end

  def destroy?
    create? && user.global_role_level > record.global_role_level
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.global_role?

      scope.joins(:roles).where(roles: { resource_id: user.roles.select(:resource_id) }).distinct
    end
  end

  private

  def users_in_same_org?
    !!user.roles.pluck(:resource_id).intersect?(record.roles.pluck(:resource_id))
  end
end
