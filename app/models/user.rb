# frozen_string_literal: true

class User < ApplicationRecord
  has_many :authentication_tokens, dependent: :destroy
  rolify before_add: :before_add_role, strict: true
  validates :email, presence: true
  validates :email, uniqueness: true, allow_blank: true

  devise :trackable, :token_authenticatable, :omniauthable, omniauth_providers: [:google_oauth2]

  def role_level_in(organization)
    levels = roles.global.map(&:level)
    levels << local_role_level_in(organization)
    levels.max
  end

  def role_in(organization)
    # Returns only an explicit role in the passed organization, not including global roles
    roles.find_by resource_id: organization.id
  end

  def administrator?(organization = nil)
    has_cached_role?(:admin, organization) || global_administrator?
  end

  def global_role?
    roles.global.present?
  end

  def global_role
    roles.global.first
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
    Organization.where(id: roles.pluck(:resource_id))
  end

  def member_of?(organization)
    roles.pluck(:resource_id).include?(organization.id)
  end

  def read_only?
    (roles.pluck(:name).map(&:to_sym) - Role::READ_ONLY_ROLES).empty?
  end

  private

  def before_add_role(role)
    raise ActiveRecord::Rollback if Role::LOCAL_ROLES[role.symbol].nil? && Role::GLOBAL_ROLES[role.symbol].nil?
    raise ActiveRecord::Rollback if roles.pluck(:resource_id).include?(role.resource_id)
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

      response = client.request(:get, Rails.configuration.google_token_info_url, params: { id_token: id_token }).parsed
      User.find_by(email: response['email'])
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
      User.count.zero?
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
