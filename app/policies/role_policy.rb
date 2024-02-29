class RolePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope if user.global_administrator?

      scope.where(resource_id: user.organizations.select(:id))
    end
  end
end
