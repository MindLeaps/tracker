# frozen_string_literal: true

FactoryBot.define do
  factory :student do
    sequence(:mlid) { |n| " #{Faker::Lorem.characters(number: 1)}#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    dob { Faker::Time.between from: 20.years.ago, to: 10.years.ago }
    estimated_dob { Faker::Boolean.boolean true_ratio: 0.2 }
    gender { %w[male female].sample }
    group { create :group }
    tags { create_list :tag, 3 }
    transient do
      grades { {} }
    end

    factory :graded_student do
      after :create do |student, evaluator|
        unless evaluator.grades.empty?
          subject = create(
            :subject_with_skills,
            skill_names: evaluator.grades.keys,
            organization: student.group.chapter.organization
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
