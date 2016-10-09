# frozen_string_literal: true
class GradeDescriptor < ApplicationRecord
  belongs_to :skill

  validates :mark, :skill, presence: true
  validates :mark, uniqueness: { scope: :skill_id }
end
