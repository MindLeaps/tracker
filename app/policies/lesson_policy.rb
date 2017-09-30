# frozen_string_literal: true

class LessonPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.global_role? || user_in_lesson_org?
  end

  def create?
    user.global_administrator? || user.is_admin_of?(lesson_organization) || user.is_teacher_of?(lesson_organization)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if user.global_role?

      scope.joins(group: :chapter).where(chapters: { organization_id: user.roles.pluck(:resource_id) }).distinct
    end
  end

  private

  def user_in_lesson_org?
    user.roles.pluck(:resource_id).include? record.group.chapter.organization_id
  end

  def lesson_organization
    record.group.chapter.organization
  end
end
