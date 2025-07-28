class OrganizationPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.global_role? || user.member_of?(record)
  end

  def create?
    user.global_administrator?
  end

  def undelete?
    destroy?
  end

  def import?
    import_students?
  end

  def import_students?
    add_member?
  end

  def confirm_import?
    import_students?
  end

  def add_member?
    user.global_administrator? || user.is_admin_of?(record)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.global_role?

      scope.where(id: user.roles.select(:resource_id))
    end
  end
end
