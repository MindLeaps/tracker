# frozen_string_literal: true

class GroupPolicy < ApplicationPolicy
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
      return scope.all if user.global_role?

      scope.joins(:chapter).where(chapters: { organization: user.membership_organizations })
    end
  end

  protected

  def user_in_record_organization?
    user.membership_organizations.pluck(:id).include?(record.chapter.organization_id)
  end
end
