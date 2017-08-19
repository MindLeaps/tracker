# frozen_string_literal: true

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
        scope.where(organization: user.organizations)
      end
    end
  end
end
