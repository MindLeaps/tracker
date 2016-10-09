# frozen_string_literal: true
class Group < ActiveRecord::Base
  validates :group_name, presence: true
  validates :group_name, uniqueness: {
    scope: :chapter_id,
    message: ->(object, data) { "Group \"#{data[:value]}\" already exists in #{object.chapter_name} chapter" }
  }

  belongs_to :chapter
  has_many :students
  has_many :lessons

  delegate :chapter_name, to: :chapter, allow_nil: true

  def group_chapter_name
    "#{group_name} - #{chapter_name}"
  end
end
