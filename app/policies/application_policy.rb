class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.global_role?
  end

  def show?
    user.global_role? || user_in_record_organization?
  end

  def create?
    new? && user.administrator?(record.organization)
  end

  def new?
    !user.read_only?
  end

  def update?
    create?
  end

  def edit?
    update?
  end

  def destroy?
    create?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope
    end
  end

  protected

  def user_in_record_organization?
    user_org_ids.include?(record.organization_id)
  end

  def user_org_ids
    user.roles.pluck(:resource_id)
  end
end
