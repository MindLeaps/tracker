# frozen_string_literal: true

class StudentTag < ApplicationRecord
  belongs_to :student
  belongs_to :tag

  validates :student, presence: true
  validates :tag, presence: true

  delegate :organization_name, to: :organization, allow_nil: true
end
