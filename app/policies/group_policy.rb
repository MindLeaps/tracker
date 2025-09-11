class GroupPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    user.administrator?(record.chapter.organization) || user.is_teacher_of?(record.chapter.organization)
  end

  def undelete?
    destroy?
  end

  def export?
    show?
  end

  def enroll_students?
    update?
  end

  def confirm_enrollments?
    enroll_students?
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
    user.membership_organizations.ids.include?(record.chapter.organization_id)
  end
end
