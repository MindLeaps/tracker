# == Schema Information
#
# Table name: groups
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  group_name :string           default(""), not null
#  mlid       :string(2)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  chapter_id :integer
#
# Indexes
#
#  index_groups_on_chapter_id  (chapter_id)
#  unique_mlid_per_chapter_id  (mlid,chapter_id) UNIQUE
#
# Foreign Keys
#
#  groups_chapter_id_fk  (chapter_id => chapters.id)
#
class Group < ApplicationRecord
  include Mlid
  validates :group_name, presence: true
  validates :group_name, uniqueness: {
    scope: :chapter_id,
    message: ->(object, data) { "Group \"#{data[:value]}\" already exists in #{object.chapter_name} chapter" }
  }
  validates :mlid, uniqueness: { scope: :chapter_id }, length: { maximum: 2 }

  belongs_to :chapter
  has_many :students, dependent: :restrict_with_error
  has_many :lessons, dependent: :restrict_with_error

  delegate :chapter_name, to: :chapter, allow_nil: true

  scope :by_chapter, ->(chapter_id) { where chapter_id: }

  def group_chapter_name
    "#{group_name} - #{chapter_name}"
  end

  def chapter_group_name_with_full_mlid
    "#{chapter_name} - #{group_name}: #{full_mlid}"
  end

  def full_mlid
    "#{chapter.full_mlid}-#{mlid}"
  end

  def delete_group_and_dependents
    transaction do
      self.deleted_at = Time.zone.now

      Student.where(group_id: id, deleted_at: nil).find_each { |student| student.update(deleted_at:) }
      Lesson.where(group_id: id, deleted_at: nil).find_each do |lesson|
        lesson.update(deleted_at:)
        Grade.where(lesson_id: lesson.id, deleted_at: nil).find_each { |grade| grade.update(deleted_at:) }
      end
    end
  end

  def restore_group_and_dependents
    transaction do
      Student.where(group_id: id, deleted_at:).find_each { |student| student.update(deleted_at: nil) }
      Lesson.where(group_id: id, deleted_at:).find_each do |lesson|
        lesson.update(deleted_at: nil)
        Grade.where(lesson_id: lesson.id, deleted_at:).find_each { |grade| grade.update(deleted_at: nil) }
      end

      self.deleted_at = nil
    end
  end
end
