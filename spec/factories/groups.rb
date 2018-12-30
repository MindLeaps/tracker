# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:group_name) { |n| "#{Faker::StarWars.vehicle}-#{n}" }
    chapter { create :chapter }
  end
end
