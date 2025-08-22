# == Schema Information
#
# Table name: organization_summaries
#
#  id                :integer          primary key
#  chapter_count     :integer
#  country           :string
#  deleted_at        :datetime
#  group_count       :integer
#  organization_mlid :string(3)
#  organization_name :string
#  student_count     :integer
#  created_at        :datetime
#  updated_at        :datetime
#
class OrganizationSummary < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search, against: [:organization_name, :country], using: { tsearch: { prefix: true } }
  self.primary_key = :id

  def readonly?
    true
  end

  def self.policy_class
    OrganizationPolicy
  end
end
