# frozen_string_literal: true

FactoryBot.define do
  factory :tag do
    tag_name { Faker::Blood.group }
    organization { create :organization }
    shared { true }
  end
end
