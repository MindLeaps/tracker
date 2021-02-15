# frozen_string_literal: true

FactoryBot.define do
  factory :chapter do
    sequence(:chapter_name) { |n| "#{Faker::Movies::StarWars.planet}-#{n}" }
    organization
    sequence(:mlid) { |n| n.to_s(36).rjust(2, '0').upcase }
  end
end
