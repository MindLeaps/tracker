class Assignment < ApplicationRecord
  belongs_to :skill
  belongs_to :subject

  validates :skill, presence: true
  validates :subject, presence: true
end
