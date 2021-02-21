# frozen_string_literal: true

class Group < ApplicationRecord
  validates :group_name, presence: true
  validates :group_name, uniqueness: {
    scope: :chapter_id,
    message: ->(object, data) { "Group \"#{data[:value]}\" already exists in #{object.chapter_name} chapter" }
  }
  validates :mlid, presence: true, uniqueness: { scope: :chapter_id }, format: { with: /\A[A-Za-z0-9]+\Z/ }

  belongs_to :chapter
  has_many :students, dependent: :restrict_with_error
  has_many :lessons, dependent: :restrict_with_error

  delegate :chapter_name, to: :chapter, allow_nil: true
  delegate :full_mlid, to: :chapter, allow_nil: true

  scope :by_chapter, ->(chapter_id) { where chapter_id: chapter_id }

  def group_chapter_name
    "#{group_name} - #{chapter_name}"
  end

  def group_chapter_name_with_mlids
    "#{group_name} - #{chapter_name}: #{full_mlid}"
  end
end
