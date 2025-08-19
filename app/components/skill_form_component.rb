class SkillFormComponent < ViewComponent::Base
  include Turbo::FramesHelper

  def initialize(skill:, action:, current_user:)
    @skill = skill
    @action = action
    @permitted_organizations = OrganizationPolicy::Scope.new(current_user, Organization).resolve.order(organization_name: :asc)
  end
end
