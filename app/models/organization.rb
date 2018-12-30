# frozen_string_literal: true

class Organization < ApplicationRecord
  resourcify
  validates :organization_name, presence: true, uniqueness: true

  has_many :chapters, dependent: :restrict_with_error

  def add_user_with_role(email, role)
    return false unless Role::LOCAL_ROLES.key? role

    user = User.find_or_create_by!(email: email)
    return false if user.member_of?(self)

    RoleService.update_local_role user, role, self
  end

  def members
    User.includes(:users_roles, :roles).where('roles.resource_id' => id)
  end
end
