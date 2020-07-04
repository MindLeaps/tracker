# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    tag_name { Faker::Games::Pokemon.name }
    organization { create :organization }
    shared { true }
  end
end
