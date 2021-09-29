# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_summaries
#
#  id                :integer          primary key
#  chapter_count     :bigint
#  organization_name :string
#  created_at        :datetime
#  updated_at        :datetime
#
class OrganizationSummary < ApplicationRecord
  self.primary_key = :id

  def readonly?
    true
  end
end
