class StudentPolicy < ApplicationPolicy
  def index?
    true
  end

  def performance?
    show?
  end

  def details?
    show?
  end

  def create?
    user.administrator?(record&.organization) || user.is_teacher_of?(record&.organization)
  end

  def undelete?
    destroy?
  end

  def import?
    import_students?
  end

  def import_students?
    user.global_role?
  end

  def confirm_import?
    import_students?
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

  def user_in_record_organization?
    user_org_ids.include?(record.organization.id)
  end
end
