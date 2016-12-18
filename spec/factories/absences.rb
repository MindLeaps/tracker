# frozen_string_literal: true
FactoryGirl.define do
  factory :absence do
    student { create :student }
    lesson { create :lesson }
  end
end
