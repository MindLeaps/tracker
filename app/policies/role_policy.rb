# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope if user.global_administrator?
      scope.where(resource_id: user.organizations.pluck(:id))
    end
  end
end
