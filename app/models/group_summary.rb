# frozen_string_literal: true

class GroupSummary < ApplicationRecord
  self.primary_key = :id

  def readonly?
    true
  end
end
