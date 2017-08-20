# frozen_string_literal: true

class User < ApplicationRecord
  has_many :authentication_tokens
  rolify before_add: :before_add_role
  validates :email, presence: true
  validates :email, uniqueness: true, allow_blank: true

  devise :trackable, :token_authenticatable, :omniauthable, omniauth_providers: [:google_oauth2]

  def role_level_in(organization)
    levels = global_roles.map(&:role_level)
    levels << local_role_level_in(organization)
    levels.max
  end

  def global_roles
    roles.where resource_id: nil
  end

  def role_in(organization)
    # Returns only an explicit role in the passed organization, not including global roles
    roles.find_by resource_id: organization.id
  end

  def update_role(new_role)
    return if has_role? new_role

    Role::ROLES.keys.each { |role| revoke role }
    add_role new_role
  end

  def update_role_in(new_role, org)
    ret = true
    User.transaction do
      unless has_role? new_role, org
        revoke_role_in org
        unless grant_role_in new_role, org
          ret = false
          raise ActiveRecord::Rollback
        end
      end
    end
    ret
  end

  def administrator?(organization = nil)
    is_admin_of?(organization) || is_super_admin?
  end

  def organizations
    return Organization.all if administrator?

    membership_organizations
  end

  def global_administrator?
    is_admin? || is_super_admin?
  end

  def membership_organizations
    # All organizations in which this user has an explicit role, not including global roles
    Organization.where(id: roles.pluck(:resource_id))
  end

  def grant_role_in(role, organization)
    add_role role, organization
  rescue ActiveRecord::RecordNotSaved
    return nil
  end

  private

  def before_add_role(role)
    raise ActiveRecord::Rollback if Role::ROLES[role.name.to_sym].nil?
    raise ActiveRecord::Rollback if already_member_of? role.resource_id
  end

  def already_member_of?(organization_id)
    roles.where(resource_id: organization_id).count.positive?
  end

  def local_role_level_in(organization)
    # Role level in explicit organization, excluding global roles
    role = role_in organization
    return Role::MINIMAL_ROLE_LEVEL if role.nil?
    role.role_level
  end

  def revoke_role_in(org)
    role = role_in org
    return if role.nil?
    revoke role.name.to_sym, org
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
