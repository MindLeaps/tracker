class OrganizationFormComponent < ViewComponent::Base
  attr_reader :mlid

  def initialize(organization:, action:, cancel: false)
    @organization = organization
    @action = action
    @organization.mlid = MindleapsIdService.generate_organization_mlid unless @organization.mlid
    @cancel = cancel
    @countries = Country.all
  end
end
