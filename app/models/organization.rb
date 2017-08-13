# frozen_string_literal: true

class Organization < ApplicationRecord
  resourcify
  validates :organization_name, presence: true, uniqueness: true

  has_many :chapters
  has_many :students

  def add_user_with_role(email, role)
    return false unless Role::ROLES.keys.include? role

    user = User.find_or_create_by!(email: email)
    return false if user.invalid?

    user.grant_role_in role, self
  end

  def members
    User.includes(:users_roles, :roles).where('roles.resource_id' => id)
  end
end
