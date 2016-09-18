class GradeDescriptor < ApplicationRecord
  belongs_to :skill

  validates :mark, :skill, presence: true
end
