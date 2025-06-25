# == Schema Information
#
# Table name: roles
#
#  id            :integer          not null, primary key
#  name          :string
#  resource_type :string
#  created_at    :datetime
#  updated_at    :datetime
#  resource_id   :integer
#
# Indexes
#
#  index_roles_on_name                                    (name)
#  index_roles_on_name_and_resource_type_and_resource_id  (name,resource_type,resource_id)
#
class Role < ApplicationRecord
  # rubocop:disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :users, join_table: :users_roles
  # rubocop:enable Rails/HasAndBelongsToMany

  belongs_to :resource,
             polymorphic: true,
             inverse_of: :roles,
             optional: true

  validates :resource_type,
            inclusion: { in: Rolify.resource_types },
            allow_nil: true

  validate :correct_role_scope

  scopify

  def symbol
    name.to_sym
  end

  def level
    ROLE_LEVELS[symbol]
  end

  def label
    I18n.t(symbol)
  end

  def global?
    GLOBAL_ROLES.key?(symbol)
  end

  def local?
    !global?
  end

  GLOBAL_ROLES = {
    super_admin: 'Super Administrator',
    global_admin: 'Global Administrator',
    global_guest: 'Global Guest',
    global_researcher: 'Global Researcher'
  }.freeze

  LOCAL_ROLES = {
    admin: 'Administrator',
    teacher: 'Teacher',
    researcher: 'Researcher',
    guest: 'Guest'
  }.freeze

  ROLE_LEVELS = {
    super_admin: 1000,
    global_admin: 800,
    admin: 500,
    teacher: 200,
    researcher: 100,
    global_researcher: 100,
    global_guest: 100,
    guest: 100
  }.freeze

  READ_ONLY_ROLES = %i[global_guest guest global_researcher researcher].freeze

  MINIMAL_ROLE_LEVEL = 0

  class << self
    def max_role_level(roles)
      roles.map(&:level).max || MINIMAL_ROLE_LEVEL
    end
  end

  private

  def correct_role_scope
    errors.add :resource_id, "#{GLOBAL_ROLES[symbol]} cannot be a local role." if invalid_global_role?
    errors.add :resource_id, "#{LOCAL_ROLES[symbol]} cannot be a global role." if invalid_local_role?
  end

  def invalid_global_role?
    GLOBAL_ROLES.key?(symbol) && resource_id.present?
  end

  def invalid_local_role?
    LOCAL_ROLES.key?(symbol) && resource_id.blank?
  end
end
