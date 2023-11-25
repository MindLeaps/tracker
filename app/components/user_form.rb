# frozen_string_literal: true

class UserForm < ViewComponent::Base
  def initialize(user:, action:)
    @user = user
    @action = action
  end
end
