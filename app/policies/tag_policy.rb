class TagPolicy < ApplicationPolicy
  def create?
    new? && (user.global_administrator? || user.is_admin_of?(record.organization))
  end

  def destroy?
    create?
  end

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
      scope.where(organization_id:).or(scope.where(shared: true))
    end
  end
end
