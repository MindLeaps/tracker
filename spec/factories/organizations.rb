# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence(:organization_name) { |n| "#{Faker::Company.name}-#{n}" }
  end
end
