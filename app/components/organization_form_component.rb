class OrganizationFormComponent < ViewComponent::Base
  attr_reader :mlid

  def initialize(organization:, countries:, action:, cancel: false)
    @organization = organization
    @countries = countries
    @action = action
    @organization.mlid = MindleapsIdService.generate_organization_mlid unless @organization.mlid
    @cancel = cancel
  end
end
