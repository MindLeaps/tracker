# frozen_string_literal: true
class Organization < ApplicationRecord
  resourcify
  validates :organization_name, presence: true, uniqueness: true

  has_many :chapters
  has_many :students
end
