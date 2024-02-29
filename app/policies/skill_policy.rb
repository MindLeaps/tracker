class SkillPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    super || (user_org_ids && record.subjects.pluck(:organization_id)).present?
  end

  def new?
    user.administrator?
  end

  def create?
    user.administrator? record.organization
  end

  def destroy?
    create?
  end

  def undelete?
    destroy?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.global_role?

      scope.joins('LEFT JOIN assignments on skill_id = skills.id LEFT JOIN subjects on subject_id = subjects.id')
           .where('skills.organization_id IN (:org_ids) OR subjects.organization_id IN (:org_ids)', org_ids: user.roles.select(:resource_id))
    end
  end
end
