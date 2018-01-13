# frozen_string_literal: true

class Membership
  include ActiveModel::Model

  attr_accessor :user, :role, :org

  def initialize(user: nil, role: nil, org: nil)
    @user = user
    @role = role
    @org = org
  end
end
