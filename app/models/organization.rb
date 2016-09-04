class Organization < ApplicationRecord
  validates :organization_name, presence: true
end
