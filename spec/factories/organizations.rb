# frozen_string_literal: true

FactoryBot.define do
  factory :organization do
    sequence(:organization_name) { |n| "#{Faker::Company.name}-#{n}" }
    sequence(:mlid) { |n| n.to_s(36).rjust(3, '0').upcase }
  end
end
