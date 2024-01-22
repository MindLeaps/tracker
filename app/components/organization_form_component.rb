# frozen_string_literal: true

class OrganizationFormComponent < ViewComponent::Base
  attr_reader :mlid

  def initialize(organization:, action:, cancel: false)
    @organization = organization
    @action = action
    @organization.mlid = MindleapsIdService.generate_organization_mlid unless @organization.mlid
    @cancel = cancel
  end
end
