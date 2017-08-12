# frozen_string_literal: true

class Organization < ApplicationRecord
  resourcify
  validates :organization_name, presence: true, uniqueness: true

  has_many :chapters
  has_many :students

  def add_user_with_role(email, role)
    return false unless Role::ROLES.keys.include? role

    user = User.find_by(email: email) || User.new(email: email)

    user.add_role role, self
    user.save
  end

  def members
    User.includes(:users_roles, :roles).where('roles.resource_id' => id)
  end
end
