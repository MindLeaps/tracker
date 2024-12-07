class EnrollmentPolicy < ApplicationPolicy
  def index?
    user_in_record_organization?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.all if user.global_role?

      scope.joins(group: :chapter).where(group: { chapters: { organization_id: user.membership_organizations } })
    end
  end

  def user_in_record_organization?
    user_org_ids.include?(record.organization.id)
  end
end
