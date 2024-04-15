# == Schema Information
#
# Table name: organizations
#
#  id                :integer          not null, primary key
#  deleted_at        :datetime
#  image             :string           default("https://placeholdit.imgix.net/~text?txtsize=23&txt=200%C3%97200&w=200&h=200")
#  mlid              :string(3)        not null
#  organization_name :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  organizations_mlid_key  (mlid) UNIQUE
#
class Organization < ApplicationRecord
  include PgSearch::Model
  include Mlid
  pg_search_scope :search, against: [:organization_name], using: { tsearch: { prefix: true } }
  resourcify
  validates :organization_name, presence: true, uniqueness: true
  validates :mlid, uniqueness: true, length: { maximum: 3 }

  has_many :chapters, dependent: :restrict_with_error
  has_many :subjects, dependent: :restrict_with_error

  def add_user_with_role(email, role)
    return false unless Role::LOCAL_ROLES.key? role

    user = User.find_or_create_by!(email:)
    return false if user.member_of?(self)

    RoleService.update_local_role user, role, self
  end

  def delete_organization_and_dependents
    transaction do
      self.deleted_at = Time.zone.now

      # rubocop:disable Rails/SkipsModelValidations
      chapters_to_update = Chapter.includes(:organization).where(organization_id: id, deleted_at: nil)
      chapter_ids = chapters_to_update.pluck(:id)
      groups_to_update = Group.includes(:chapter).where(chapters: chapter_ids, deleted_at: nil)
      group_ids = groups_to_update.pluck(:id)

      chapters_to_update.update_all(deleted_at:)
      groups_to_update.update_all(deleted_at:)
      Student.includes(:group).where(groups: group_ids, deleted_at: nil).update_all(deleted_at:)
      Lesson.includes(:group).where(groups: group_ids, deleted_at: nil).update_all(deleted_at:)
      Grade.includes(:lesson).where(lessons: { group_id: group_ids, deleted_at: }, deleted_at: nil).update_all(deleted_at:)
      # rubocop:enable Rails/SkipsModelValidations
    end
  end

  def restore_organization_and_dependents
    transaction do
      # rubocop:disable Rails/SkipsModelValidations
      chapters_to_update = Chapter.includes(:organization).where(organization_id: id, deleted_at:)
      chapter_ids = chapters_to_update.pluck(:id)
      groups_to_update = Group.includes(:chapter).where(chapters: chapter_ids, deleted_at:)
      group_ids = groups_to_update.pluck(:id)

      chapters_to_update.update_all(deleted_at: nil)
      groups_to_update.update_all(deleted_at: nil)
      Student.includes(:group).where(groups: group_ids, deleted_at:).update_all(deleted_at: nil)
      Grade.includes(:lesson).where(lessons: { group_id: group_ids, deleted_at: }, deleted_at:).update_all(deleted_at: nil)
      Lesson.includes(:group).where(groups: group_ids, deleted_at:).update_all(deleted_at: nil)
      # rubocop:enable Rails/SkipsModelValidations

      self.deleted_at = nil
    end
  end

  def members
    OrganizationMember.where(organization_id: id)
  end
end
