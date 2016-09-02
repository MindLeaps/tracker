class Chapter < ApplicationRecord
  validates :chapter_name, presence: true
  has_many :groups
  has_many :students
end
