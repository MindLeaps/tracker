class Organization < ApplicationRecord
  resourcify
  validates :organization_name, presence: true, uniqueness: true

  has_many :chapters
end
