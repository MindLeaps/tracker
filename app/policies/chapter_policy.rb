class ChapterPolicy < ApplicationPolicy
  def index?
    true
  end

  def edit?
    update?
  end

  def update?
    create?
  end

  def create?
    user.administrator? record.organization
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.global_role?

      scope.where(organization_id: user.roles.select(:resource_id))
    end
  end
end
