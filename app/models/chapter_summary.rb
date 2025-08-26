# == Schema Information
#
# Table name: chapter_summaries
#
#  id                :integer          primary key
#  chapter_mlid      :string(2)
#  chapter_name      :string
#  deleted_at        :datetime
#  full_mlid         :text
#  group_count       :integer
#  organization_mlid :string(3)
#  organization_name :string
#  student_count     :integer
#  created_at        :datetime
#  updated_at        :datetime
#  organization_id   :integer
#
class ChapterSummary < ApplicationRecord
  include PgSearch::Model

  self.primary_key = :id
  singleton_class.send(:alias_method, :table_order_chapters, :table_order)

  pg_search_scope :search, against: [:chapter_name, :organization_name, :chapter_mlid, :organization_mlid, :full_mlid], using: { tsearch: { prefix: true } }

  belongs_to :organization
  self.primary_key = :id

  def readonly?
    true
  end

  def self.policy_class
    ChapterPolicy
  end
end
