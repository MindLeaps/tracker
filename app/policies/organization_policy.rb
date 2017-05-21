# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def show?
    user.administrator?
  end
end
