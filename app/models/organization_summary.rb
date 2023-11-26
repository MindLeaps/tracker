# frozen_string_literal: true

# == Schema Information
#
# Table name: organization_summaries
#
#  id                :integer          primary key
#  chapter_count     :integer
#  group_count       :integer
#  organization_mlid :string(3)
#  organization_name :string
#  student_count     :integer
#  created_at        :datetime
#  updated_at        :datetime
#
class OrganizationSummary < ApplicationRecord
  self.primary_key = :id

  def readonly?
    true
  end
end
