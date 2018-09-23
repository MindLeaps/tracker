# frozen_string_literal: true

class GroupSummary < ApplicationRecord
  belongs_to :chapter
  self.primary_key = :id

  def readonly?
    true
  end
end
