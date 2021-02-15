# frozen_string_literal: true

class StudentTableRow < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: [:first_name, :last_name, :full_mlid], associated_against: {
    tags: :tag_name
  }, using: { tsearch: { prefix: true } }

  self.primary_key = :id
  belongs_to :group
  has_many :student_tags, foreign_key: :student_id, inverse_of: :student, dependent: :restrict_with_exception
  has_many :tags, through: :student_tags

  enum gender: { M: 'male', F: 'female' }

  def readonly?
    true
  end
end
