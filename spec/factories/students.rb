# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    sequence(:mlid) { |n| " #{Faker::Lorem.characters(1)}#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    dob { Faker::Time.between 20.years.ago, 10.years.ago }
    estimated_dob { Faker::Boolean.boolean 0.2 }
    gender { %w[male female].sample }
    organization
    transient do
      grades { {} }
    end

    factory :student_in_group do
      group { create :group, chapter: create(:chapter, organization: organization) }
    end

    factory :graded_student do
      group { create :group, chapter: create(:chapter, organization: organization) }
      after :create do |student, evaluator|
        unless evaluator.grades.empty?
          subject = create(
            :subject_with_skills,
            skill_names: evaluator.grades.keys,
            organization: student.organization
          )
          (0..evaluator.grades.values.map(&:length).max - 1).each do |i|
            create(
              :lesson_with_grades,
              subject: subject,
              group: student.group,
              date: 1.year.ago + i.days,
              student_grades: { student.id => evaluator.grades.transform_values { |v| v[i] } }
            )
          end
        end
      end
    end
  end
end
