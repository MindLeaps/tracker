# frozen_string_literal: true

class RoleService
  class << self
    def update_local_role(user, new_role, org)
      role_update_transaction user, new_role, org
      true
    rescue ActiveRecord::RecordNotSaved
      return false
    end

    private

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
      user.revoke role.name.to_sym, org
    end
  end
end
