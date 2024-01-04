# frozen_string_literal: true

class StudentTagFormComponent < ViewComponent::Base
  def initialize(tag:, action:, current_user:)
    @tag = tag
    @action = action
    @permitted_organizations = OrganizationPolicy::Scope.new(current_user, Organization).resolve.order(organization_name: :asc)
  end
end
