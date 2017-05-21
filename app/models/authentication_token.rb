# frozen_string_literal: true

class AuthenticationToken < ApplicationRecord
  belongs_to :user
end
