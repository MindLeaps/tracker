# frozen_string_literal: true

class GradeDescriptor < ApplicationRecord
  belongs_to :skill

  scope :by_skill, ->(skill_id) { where skill_id: skill_id }

  before_validation :update_uids
  validates :mark, :skill, presence: true
  validates :mark, uniqueness: { scope: :skill_id }

  def update_uids
    return if skill&.id.nil?

    self.skill_uid = skill.reload.uid
  end
end
