# frozen_string_literal: true

class OrganizationSummary < ApplicationRecord
  self.primary_key = :id

  def readonly?
    true
  end
end
