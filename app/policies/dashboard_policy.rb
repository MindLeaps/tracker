class DashboardPolicy < ApplicationPolicy
  def show?
    user.present?
  end
end
