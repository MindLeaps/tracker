# == Schema Information
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  current_sign_in_at :datetime
#  current_sign_in_ip :string
#  email              :string           default(""), not null
#  image              :string
#  last_sign_in_at    :datetime
#  last_sign_in_ip    :string
#  name               :string
#  provider           :string
#  sign_in_count      :integer          default(0), not null
#  uid                :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search, against: [:name, :email], using: { tsearch: { prefix: true } }

  has_many :authentication_tokens, dependent: :destroy
  rolify before_add: :before_add_role, strict: true
  validates :email, presence: true
  validate :email_has_at_character
  validates :email, uniqueness: true, allow_blank: true

  devise :trackable, :token_authenticatable, :omniauthable, omniauth_providers: [:google_oauth2]

  def email_has_at_character
    errors.add(:email, :invalid_email) if email.present? && email.exclude?('@')
  end

  def role_level_in(organization)
    [global_role_level, local_role_level_in(organization)].max
  end

  def global_role_level
    return Role::MINIMAL_ROLE_LEVEL if roles.global.empty?

    roles.global.map(&:level).max
  end

  def role_in(organization)
    # Returns only an explicit role in the passed organization, not including global roles
    roles.find_by resource_id: organization.id
  end

  def administrator?(organization = nil)
    global_administrator? || if organization.nil?
                               has_cached_role?(:admin, :any) else
                                                                has_cached_role?(:admin, organization)
                             end
  end

  def global_role?
    !global_role.nil?
  end

  def global_role
    roles.find { |r| Role::GLOBAL_ROLES.key? r.symbol }
  end

  def organizations
    return Organization.all if global_role?

    membership_organizations
  end

  def global_administrator?
    has_cached_role?(:global_admin) || has_cached_role?(:super_admin)
  end

  def membership_organizations
    # All organizations in which this user has an explicit role, not including global roles
    Organization.where(id: roles.select(:resource_id))
  end

  def member_of?(organization)
    roles.pluck(:resource_id).include?(organization.id)
  end

  def read_only?
    (roles.pluck(:name).map(&:to_sym) - Role::READ_ONLY_ROLES).empty?
  end

  private

  def before_add_role(role)
    raise ActiveRecord::RecordInvalid if Role::LOCAL_ROLES[role.symbol].nil? && Role::GLOBAL_ROLES[role.symbol].nil?
    raise ActiveRecord::RecordInvalid if roles.pluck(:resource_id).include?(role.resource_id)
  end

  def local_role_level_in(organization)
    # Role level in explicit organization, excluding global roles
    role = role_in organization
    return Role::MINIMAL_ROLE_LEVEL if role.nil?

    role.level
  end

  class << self
    def from_omniauth(auth)
      user = get_user_from_auth auth
      return update_user_from_omniauth user, auth if user
      return create_first_user auth if first_user?

      empty_user
    end

    def from_id_token(id_token)
      client = OAuth2::Client.new(Rails.configuration.google_client_id, Rails.configuration.google_client_secret)

      response = client.request(:get, Rails.configuration.google_token_info_url, params: { id_token: }).parsed
      User.find_for_authentication(email: response['email'])
    end

    private

    def update_user_from_omniauth(user, auth)
      user.update auth_params auth
      user
    end

    def empty_user
      User.new
    end

    def create_first_user(auth)
      user = User.new auth_params auth
      user.save
      user.add_role :super_admin
      user
    end

    def get_user_from_auth(auth)
      User.find_by email: auth['info']['email']
    end

    def first_user?
      User.none?
    end

    def auth_params(auth)
      {
        uid: auth['uid'],
        name: auth['info']['name'],
        email: auth['info']['email'],
        provider: auth.provider,
        image: auth['info']['image']
      }
    end
  end
end
