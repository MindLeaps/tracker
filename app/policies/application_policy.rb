# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.global_administrator?
  end

  def show?
    scope.where(id: record.id).exists?
  end

  def create?
    user.global_administrator?
  end

  def new?
    create?
  end

  def update?
    user.global_administrator?
  end

  def edit?
    update?
  end

  def destroy?
    user.global_administrator?
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
