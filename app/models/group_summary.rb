# == Schema Information
#
# Table name: group_summaries
#
#  id                :integer          primary key
#  chapter_mlid      :string(2)
#  chapter_name      :string
#  deleted_at        :datetime
#  full_mlid         :text
#  group_name        :string
#  mlid              :string(2)
#  organization_mlid :string(3)
#  organization_name :string
#  student_count     :bigint
#  created_at        :datetime
#  chapter_id        :integer
#  organization_id   :integer
#
class GroupSummary < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search, against: [:group_name, :chapter_name, :organization_name, :mlid, :chapter_mlid, :organization_mlid, :full_mlid],
                           using: { tsearch: { prefix: true } }

  belongs_to :chapter
  self.primary_key = :id

  def readonly?
    true
  end

  def self.policy_class
    GroupPolicy
  end
end
