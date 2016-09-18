class Skill < ApplicationRecord
  validates :skill_name, :organization, presence: true

  belongs_to :organization
  has_many :assignments, dependent: :destroy
  has_many :subjects, through: :assignments
end
