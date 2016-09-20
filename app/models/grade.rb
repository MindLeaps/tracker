class Grade < ApplicationRecord
  validates :lesson, :student, :grade_descriptor, presence: true

  belongs_to :lesson
  belongs_to :student
  belongs_to :grade_descriptor
end
