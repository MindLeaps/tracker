# frozen_string_literal: true

class ChapterSummary < ApplicationRecord
  self.primary_key = :id

  def readonly?
    true
  end
end
