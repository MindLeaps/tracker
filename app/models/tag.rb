# frozen_string_literal: true

class Tag < ApplicationRecord
  has_many :student_tags, dependent: :destroy
  has_many :students, through: :student_tags
  belongs_to :organization

  validates :tag_name, presence: true
  validates :organization, presence: true
end
