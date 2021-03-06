# frozen_string_literal: true

class Organization < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search, against: [:organization_name], using: { tsearch: { prefix: true } }
  resourcify
  validates :organization_name, presence: true, uniqueness: true
  validates :mlid, presence: true, uniqueness: true, format: { with: /\A[A-Za-z0-9]+\Z/ }

  has_many :chapters, dependent: :restrict_with_error

  def add_user_with_role(email, role)
    return false unless Role::LOCAL_ROLES.key? role

    user = User.find_or_create_by!(email: email)
    return false if user.member_of?(self)

    RoleService.update_local_role user, role, self
  end

  def members
    User.includes(:roles_users, :roles).where('roles.resource_id' => id)
  end
end
