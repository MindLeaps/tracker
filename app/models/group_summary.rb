# frozen_string_literal: true

class GroupSummary < ApplicationRecord
  include PgSearch
  pg_search_scope :search, against: [:group_name], using: { tsearch: { prefix: true } }

  belongs_to :chapter
  self.primary_key = :id

  def readonly?
    true
  end
end
