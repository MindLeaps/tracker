# == Schema Information
#
# Table name: organization_summaries
#
#  id                :integer          primary key
#  chapter_count     :integer
#  country_name      :string
#  deleted_at        :datetime
#  group_count       :integer
#  organization_mlid :string(3)
#  organization_name :string
#  student_count     :integer
#  created_at        :datetime
#  updated_at        :datetime
#
require 'rails_helper'

RSpec.describe OrganizationSummary, type: :model do
  describe 'no organizations present' do
    it 'returns no results' do
      expect(OrganizationSummary.all).to be_empty
    end
  end

  describe 'finding by id' do
    it 'finds the organization summary by organization id' do
      organization = create :organization
      expect(OrganizationSummary.find(organization.id).organization_name).to eq organization.organization_name
    end
  end

  context 'multiple organizations present' do
    organizations = []
    before :each do
      organizations = create_list :organization, 3
      create_list :chapter, 3, organization: organizations[0]
      create_list :chapter, 2, organization: organizations[0], deleted_at: Time.zone.now

      create_list :chapter, 2, organization: organizations[1], deleted_at: Time.zone.now
    end

    it 'calculates the correct number of chapters, excluding deleted ones' do
      expect(OrganizationSummary.find(organizations[0].id).chapter_count).to eq 3
      expect(OrganizationSummary.find(organizations[1].id).chapter_count).to eq 0
      expect(OrganizationSummary.find(organizations[2].id).chapter_count).to eq 0
    end
  end
end
