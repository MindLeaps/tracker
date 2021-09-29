# frozen_string_literal: true

# == Schema Information
#
# Table name: chapter_summaries
#
#  id                :integer          primary key
#  chapter_mlid      :string(2)
#  chapter_name      :string
#  deleted_at        :datetime
#  full_mlid         :text
#  group_count       :bigint
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

  pg_search_scope :search, against: [:chapter_name, :organization_name, :chapter_mlid, :organization_mlid, :full_mlid], using: { tsearch: { prefix: true } }

  def readonly?
    true
  end
end
