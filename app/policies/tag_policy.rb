# frozen_string_literal: true

class TagPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.global_role?
        scope.all
      else
        scope.where(organization_id: user.membership_organizations).or(scope.where(shared: true))
      end
    end

    def resolve_for_organization_id(organization_id)
      scope.where(organization_id: organization_id).or(scope.where(shared: true))
    end
  end
end
