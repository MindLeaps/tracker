# frozen_string_literal: true

class Absence < ApplicationRecord
  before_validation :update_uid
  belongs_to :student
  belongs_to :lesson

  validates :lesson_uid, presence: true

  validates :student, uniqueness: {
    scope: :lesson_id
  }

  def update_uid
    self.lesson_uid = lesson&.reload&.uid
  end
end
