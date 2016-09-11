class OrganizationPolicy < ApplicationPolicy
  def show?
    user.administrator?
  end
end
