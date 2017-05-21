# frozen_string_literal: true

FactoryGirl.define do
  factory :group do
    sequence(:group_name) { |n| "#{Faker::StarWars.vehicle}-#{n}" }
  end
end
