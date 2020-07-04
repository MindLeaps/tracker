# frozen_string_literal: true

class StudentTagTableRow < ApplicationRecord
  belongs_to :organization

  def policy_class
    TagPolicy
  end

  include PgSearch::Model
  pg_search_scope :search, against: [:tag_name, :organization_name], using: { tsearch: { prefix: true } }

  self.primary_key = :id

  def readonly?
    true
  end
end
