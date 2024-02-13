# frozen_string_literal: true

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
  pg_search_scope :search, against: [:organization_name], using: { tsearch: { prefix: true } }
  resourcify
  validates :organization_name, presence: true, uniqueness: true
  validates :mlid, presence: true, uniqueness: true, format: { with: /\A[A-Za-z0-9]{1,3}\Z/ }

  has_many :chapters, dependent: :restrict_with_error
  has_many :subjects, dependent: :restrict_with_error

  def add_user_with_role(email, role)
    return false unless Role::LOCAL_ROLES.key? role

    user = User.find_or_create_by!(email:)
    return false if user.member_of?(self)

    RoleService.update_local_role user, role, self
  end

  def members
    OrganizationMember.where(organization_id: id)
  end
end
