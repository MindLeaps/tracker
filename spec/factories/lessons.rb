# == Schema Information
#
# Table name: lessons
#
#  id         :uuid             not null, primary key
#  date       :date             not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group_id   :integer          not null
#  old_id     :integer          not null
#  subject_id :integer          not null
#
# Indexes
#
#  index_lessons_on_group_id                          (group_id)
#  index_lessons_on_group_id_and_subject_id_and_date  (group_id,subject_id,date) UNIQUE WHERE (deleted_at IS NULL)
#  index_lessons_on_subject_id                        (subject_id)
#  lesson_uuid_unique                                 (id) UNIQUE
#
# Foreign Keys
#
#  lessons_group_id_fk    (group_id => groups.id)
#  lessons_subject_id_fk  (subject_id => subjects.id)
#
FactoryBot.define do
  factory :lesson do
    sequence(:date) { |n| n.days.ago }
    group { create :group }
    subject { create :subject_with_skills }
    id { SecureRandom.uuid }
    transient do
      student_grades { {} }
    end

    factory :lesson_with_grades do
      after :create do |lesson, evaluator|
        evaluator.student_grades.each do |student_id, skill_marks|
          skill_marks.each do |skill_name, mark|
            next unless mark

            skill = Skill.find_by(skill_name:)
            gd = GradeDescriptor.find_by(skill:, mark:)
            create :grade, student_id:, grade_descriptor: gd, lesson:
          end
        end
      end
    end
  end
end
