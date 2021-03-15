# frozen_string_literal: true

class OrganizationFormComponent < ViewComponent::Base
  attr_reader :mlid

  def initialize(organization:, action:)
    @organization = organization
    @action = action
    @mlid = @organization.mlid || MindleapsIdService.generate_organization_mlid
  end
end
