# frozen_string_literal: true

class GroupSummary < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: [:group_name, :chapter_name, :organization_name, :mlid, :chapter_mlid, :organization_mlid, :full_mlid],
                           using: { tsearch: { prefix: true } }

  belongs_to :chapter
  self.primary_key = :id

  def readonly?
    true
  end
end
