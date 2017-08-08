# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.is_super_admin? || user.is_admin?
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    user.is_super_admin? || user.is_admin?
  end

  def new?
    create?
  end

  def update?
    user.is_super_admin? || user.is_admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.is_super_admin? || user.is_admin?
  end

  def add_member?
    user.roles.map(&:policy).any? do |policy|
      if policy.respond_to?(:can_add_member?)
        policy.can_add_member?
      end
    end
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
end
