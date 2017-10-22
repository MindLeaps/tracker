# frozen_string_literal: true

FactoryBot.define do
  factory :absence do
    student { create :student }
    lesson { create :lesson }
  end
end
