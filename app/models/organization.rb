class Organization < ApplicationRecord
  validates :organization_name, presence: true, uniqueness: true

  has_many :chapters
end
