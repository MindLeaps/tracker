# frozen_string_literal: true

FactoryBot.define do
  factory :authentication_token do
    body { Faker::Code.ean }
    user_agent { 'Rails Testing' }
    user
  end
end
