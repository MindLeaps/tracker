# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OrganizationFormComponent, type: :component do
  it 'generates an MLID if the Organization does not have it' do
    expect(MindleapsIdService).to receive(:generate_organization_mlid).and_return('ABC')

    org = Organization.new
    OrganizationFormComponent.new(organization: org, action: :create)

    expect(org.mlid).to eq('ABC')
  end

  it 'does not generate an MLID if the Organization has it already' do
    expect(MindleapsIdService).not_to receive(:generate_organization_mlid)

    org = Organization.new(mlid: 'ZZZ')
    OrganizationFormComponent.new(organization: org, action: :create)
    expect(org.mlid).to eq('ZZZ')
  end
end
