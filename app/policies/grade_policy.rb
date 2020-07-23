# frozen_string_literal: true

class GradePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.global_role?

      scope.joins(lesson: { group: :chapter }).where(chapters: { organization_id: user.roles.select(:resource_id) }).distinct
    end
  end
end
