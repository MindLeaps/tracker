# frozen_string_literal: true
class Group < ApplicationRecord
  validates :group_name, presence: true
  validates :group_name, uniqueness: {
    scope: :chapter_id,
    message: ->(object, data) { "Group \"#{data[:value]}\" already exists in #{object.chapter_name} chapter" }
  }

  belongs_to :chapter
  has_many :students
  has_many :lessons

  delegate :chapter_name, to: :chapter, allow_nil: true

  scope :by_chapter, ->(chapter_id) { where chapter_id: chapter_id }

  def group_chapter_name
    "#{group_name} - #{chapter_name}"
  end
end
