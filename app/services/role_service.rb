# frozen_string_literal: true

class RoleService
  class << self
    def update_global_role(user, new_role)
      role_update_global_transaction user, new_role
      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    def update_local_role(user, new_role, org)
      role_update_transaction user, new_role, org
      true
    rescue ActiveRecord::RecordInvalid
      false
    end

    def revoke_local_role(user, org)
      User.transaction do
        user.roles.instance_scoped(org).each { |r| user.revoke r.symbol, org }
      end
    end

    def revoke_global_role(user)
      User.transaction do
        user.roles.global.each { |r| user.revoke r.symbol }
      end
    end

    private

    def role_update_global_transaction(user, new_role)
      User.transaction do
        unless user.has_role? new_role
          user.roles.global.each { |r| user.revoke r.symbol }
          user.add_role new_role
        end
      end
    end

    def role_update_transaction(user, new_role, org)
      User.transaction do
        unless user.has_role?(new_role, org)
          revoke_role_in user, org
          user.add_role new_role, org
        end
      end
    end

    def revoke_role_in(user, org)
      role = user.role_in org
      return if role.nil?

      user.revoke role.symbol, org
    end
  end
end
