# frozen_string_literal: true

FactoryGirl.define do
  factory :grade do
    lesson { create :lesson }
    student { create :student }
    grade_descriptor { create :grade_descriptor }
  end
end
