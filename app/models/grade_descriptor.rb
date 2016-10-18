# frozen_string_literal: true
class GradeDescriptor < ApplicationRecord
  belongs_to :skill

  scope :by_skill, ->(skill_id) { where skill_id: skill_id }

  validates :mark, :skill, presence: true
  validates :mark, uniqueness: { scope: :skill_id }
end
