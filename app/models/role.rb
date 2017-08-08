# frozen_string_literal: true

# rubocop:disable Rails/HasAndBelongsToMany
class Role < ApplicationRecord
  has_and_belongs_to_many :users, join_table: :users_roles

  belongs_to :resource,
             polymorphic: true,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  scopify

  ROLES = {
    super_admin: 'Super Administrator',
    admin: 'Administrator',
    teacher: 'Teacher'
  }.freeze

  ROLE_LEVELS = {
    super_admin: 3,
    admin: 2,
    teacher: 1
  }.freeze

  def policy
    self.name.classify.constantize.new
  end
end

class SuperAdmin
  def can_add_member?
    true
  end
end

class Admin
end

class Teacher
end
