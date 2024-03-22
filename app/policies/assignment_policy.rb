class AssignmentPolicy < ApplicationPolicy
  def index?
    true
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.global_role?

      scope.joins('LEFT JOIN skills on skill_id = skills.id 
                   LEFT JOIN subjects on subject_id = subjects.id')
           .where('skills.organization_id IN (:org_ids) OR subjects.organization_id IN (:org_ids)', org_ids: user.roles.select(:resource_id))
    end
  end
end
