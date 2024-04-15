# == Schema Information
#
# Table name: chapters
#
#  id              :integer          not null, primary key
#  chapter_name    :string           not null
#  deleted_at      :datetime
#  mlid            :string(2)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :integer
#
# Indexes
#
#  index_chapters_on_organization_id  (organization_id)
#  unique_mlid_per_scope              (mlid,organization_id) UNIQUE
#
# Foreign Keys
#
#  chapters_organization_id_fk  (organization_id => organizations.id)
#
class Chapter < ApplicationRecord
  include Mlid
  validates :chapter_name, presence: true
  validates :chapter_name, uniqueness: {
    scope: :organization_id,
    message: lambda do |chapter, data|
      "Chapter \"#{data[:value]}\" already exists in #{chapter.organization_name} organization"
    end
  }
  validates :mlid, uniqueness: { scope: :organization_id }, length: { maximum: 3 }

  belongs_to :organization
  has_many :groups, dependent: :restrict_with_error
  has_many :students, dependent: :restrict_with_error

  delegate :organization_name, to: :organization, allow_nil: true

  scope :by_organization, ->(organization_id) { where organization_id: }

  def display_with_mlid
    I18n.t(:display_with_mlid, name: chapter_name, mlid: full_mlid)
  end

  def full_mlid
    "#{organization.mlid}-#{mlid}"
  end

  def delete_chapter_and_dependents
    transaction do
      self.deleted_at = Time.zone.now

      # rubocop:disable Rails/SkipsModelValidations
      groups_to_update = Group.includes(:chapter).where(chapter_id: id, deleted_at: nil)
      group_ids = groups_to_update.pluck(:id)

      groups_to_update.update_all(deleted_at:)
      Student.includes(:group).where(groups: group_ids, deleted_at: nil).update_all(deleted_at:)
      Lesson.includes(:group).where(groups: group_ids, deleted_at: nil).update_all(deleted_at:)
      Grade.includes(:lesson).where(lessons: { group_id: group_ids, deleted_at: }, deleted_at: nil).update_all(deleted_at:)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def restore_chapter_and_dependents
    transaction do
      # rubocop:disable Rails/SkipsModelValidations
      groups_to_update = Group.includes(:chapter).where(chapter_id: id, deleted_at:)
      group_ids = groups_to_update.pluck(:id)

      groups_to_update.update_all(deleted_at: nil)
      Student.includes(:group).where(groups: group_ids, deleted_at:).update_all(deleted_at: nil)
      Grade.includes(:lesson).where(lessons: { group_id: group_ids, deleted_at: }, deleted_at:).update_all(deleted_at: nil)
      Lesson.includes(:group).where(groups: group_ids, deleted_at:).update_all(deleted_at: nil)
      # rubocop:enable Rails/SkipsModelValidations

      self.deleted_at = nil
    end
  end
end
