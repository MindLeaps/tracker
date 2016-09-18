class Skill < ApplicationRecord
  validates :skill_name, :organization, presence: true

  belongs_to :organization
  has_many :grade_descriptors, dependent: :destroy, inverse_of: :skill
  has_many :assignments, dependent: :destroy
  has_many :subjects, through: :assignments

  accepts_nested_attributes_for :grade_descriptors
end
