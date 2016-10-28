# frozen_string_literal: true
FactoryGirl.define do
  factory :authentication_token do
    body { Faker::Code.ean }
    user_agent { 'Rails Testing' }
  end
end
