# frozen_string_literal: true

FactoryBot.define do
  factory :group do
    sequence(:group_name) { |n| "#{Faker::Movies::StarWars.vehicle}-#{n}" }
    sequence(:mlid) { |n| n.to_s(36).rjust(2, '0').upcase }
    chapter { create :chapter }
  end
end
