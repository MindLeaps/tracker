# frozen_string_literal: true

class StudentFormComponent < ViewComponent::Base
  attr_reader :permitted_groups, :permitted_tags

  def initialize(student:, action:, current_user:)
    @student = student
    @action = action
    @permitted_groups = GroupPolicy::Scope.new(current_user, Group.includes(chapter: :organization)).resolve
    @permitted_tags = TagPolicy::Scope.new(current_user, Tag.includes(:organization)).resolve
  end
end
