# frozen_string_literal: true

FactoryBot.define do
  factory :chapter do
    sequence(:chapter_name) { |n| "#{Faker::Movies::StarWars.planet}-#{n}" }
    organization
  end
end
