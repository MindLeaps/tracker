# frozen_string_literal: true

class ChapterFormComponent < ViewComponent::Base
  attr_reader :permitted_organizations

  def initialize(chapter:, action:, current_user:)
    @chapter = chapter
    @action = action
    @permitted_organizations = OrganizationPolicy::Scope.new(current_user, Organization).resolve.order(organization_name: :asc)
  end
end
