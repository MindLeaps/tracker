# frozen_string_literal: true

class StudentPolicy < ApplicationPolicy
  def index?
    true
  end

  def undelete?
    destroy?
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
        scope.where(organization: user.membership_organizations)
      end
    end
  end
end
