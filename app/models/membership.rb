# frozen_string_literal: true

class Membership
  attr_accessor :user, :role, :org

  def initialize(user: nil, role: nil, org: nil)
    @user = user
    @role = role
    @org = org
  end
end
