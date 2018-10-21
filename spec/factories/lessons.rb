# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    sequence(:date) { |n| n.days.ago }
    group { create :group }
    subject { create :subject_with_skills }
    transient do
      student_grades { {} }
    end

    factory :lesson_with_grades do
      after :create do |lesson, evaluator|
        evaluator.student_grades.each do |student_id, skill_marks|
          skill_marks.each do |skill_name, mark|
            next unless mark

            skill = Skill.find_by skill_name: skill_name
            gd = GradeDescriptor.find_by skill: skill, mark: mark
            create :grade, student_id: student_id, grade_descriptor: gd, lesson: lesson
          end
        end
      end
    end
  end
end
