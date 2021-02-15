# frozen_string_literal: true

class ChapterSummary < ApplicationRecord
  include PgSearch::Model
  self.primary_key = :id

  pg_search_scope :search, against: [:chapter_name, :organization_name, :chapter_mlid, :organization_mlid, :full_mlid], using: { tsearch: { prefix: true } }

  def readonly?
    true
  end
end
