class StudentPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      if user.administrator?
        scope.all
      else
        users_organizations = Organization.with_role [:user, :admin]
        scope.where organization: users_organizations.to_a
      end
    end
  end
end
