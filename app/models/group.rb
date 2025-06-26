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

      # rubocop:disable Rails/SkipsModelValidations
      Student.where(group_id: id, deleted_at: nil).update_all(deleted_at:)
      Lesson.where(group_id: id, deleted_at: nil).update_all(deleted_at:)
      Grade.includes(:lesson).where(lessons: { group_id: id, deleted_at: }, deleted_at: nil).update_all(deleted_at:)
      # rubocop:enable Rails/SkipsModelValidations
      save
    end
  end

  def restore_group_and_dependents
    transaction do
      # rubocop:disable Rails/SkipsModelValidations
      Student.where(group_id: id, deleted_at:).update_all(deleted_at: nil)
      Grade.includes(:lesson).where(lessons: { group_id: id, deleted_at: }, deleted_at:).update_all(deleted_at: nil)
      Lesson.where(group_id: id, deleted_at:).update_all(deleted_at: nil)
      # rubocop:enable Rails/SkipsModelValidations

      self.deleted_at = nil
      save
    end
  end

  def next_student_mlid(existing_mlid = nil)
    last_mlid_given = existing_mlid || students.map(&:mlid).max

    return '01' if last_mlid_given.blank?

    if last_mlid_given[0] == '0'
      new_mlid = (last_mlid_given[-1].to_i + 1).to_s
      return new_mlid.length == 2 ? new_mlid : "0#{new_mlid}"
    end

    (last_mlid_given.to_i + 1).to_s
  end
end
