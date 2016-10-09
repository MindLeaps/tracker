# frozen_string_literal: true
FactoryGirl.define do
  factory :organization do
    sequence(:organization_name) { |n| "#{Faker::Company.name}-#{n}" }
  end
end
