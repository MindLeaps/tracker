class StudentTagFormComponent < ViewComponent::Base
  def initialize(tag:, action:, current_user:, cancel: false)
    @tag = tag
    @action = action
    @permitted_organizations = OrganizationPolicy::Scope.new(current_user, Organization).resolve.order(organization_name: :asc)
    @cancel = cancel
  end
end
