# frozen_string_literal: true

FactoryBot.define do
  factory :student_tag do
    student { create :student }
    tag { create :tag }
  end
end
