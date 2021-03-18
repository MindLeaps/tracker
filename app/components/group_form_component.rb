# frozen_string_literal: true

class GroupFormComponent < ViewComponent::Base
  attr_reader :permitted_chapters

  def initialize(group:, action:, current_user:)
    @group = group
    @action = action
    @permitted_chapters = ChapterPolicy::Scope.new(current_user, Chapter.order(chapter_name: :asc)).resolve
  end
end
