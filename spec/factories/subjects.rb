# frozen_string_literal: true

FactoryBot.define do
  factory :subject do
    sequence(:subject_name) { |n| "#{Faker::Educator.course}-#{n}" }
    organization { create :organization }
    transient do
      number_of_skills 5
    end

    factory :subject_with_skills do
      after(:create) { |subject, evaluator| create_list(:skill, evaluator.number_of_skills, subjects: [subject]) }
    end
  end
end
