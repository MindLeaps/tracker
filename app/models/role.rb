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
    teacher: 'Teacher',
    researcher: 'Researcher'
  }.freeze

  ROLE_LEVELS = {
    super_admin: 1000,
    admin: 500,
    teacher: 200,
    researcher: 100
  }.freeze
end
