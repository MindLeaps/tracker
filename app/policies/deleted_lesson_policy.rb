class DeletedLessonPolicy < ApplicationPolicy
  def index?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.global_role?

      scope.joins(group: :chapter).where(chapters: { organization_id: user.roles.select(:resource_id) }).distinct
    end
  end
end
