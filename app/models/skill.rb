class Skill < ApplicationRecord
  validates :skill_name, :organization, presence: true

  belongs_to :organization
end
