# == Schema Information
#
# Table name: students
#
#  id                     :integer          not null, primary key
#  country_of_nationality :text
#  deleted_at             :datetime
#  dob                    :date             not null
#  estimated_dob          :boolean          default(TRUE), not null
#  family_members         :text
#  first_name             :string           not null
#  gender                 :enum             not null
#  guardian_contact       :string
#  guardian_name          :string
#  guardian_occupation    :string
#  health_insurance       :text
#  health_issues          :text
#  hiv_tested             :boolean
#  last_name              :string           not null
#  mlid                   :string(8)        not null
#  name_of_school         :string
#  notes                  :text
#  old_mlid               :string
#  quartier               :string
#  reason_for_leaving     :string
#  school_level_completed :string
#  year_of_dropout        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  group_id               :integer
#  organization_id        :integer          not null
#  profile_image_id       :integer
#
# Indexes
#
#  index_students_on_group_id                  (group_id)
#  index_students_on_mlid_and_organization_id  (mlid,organization_id) UNIQUE
#  index_students_on_organization_id           (organization_id)
#  index_students_on_profile_image_id          (profile_image_id)
#
# Foreign Keys
#
#  fk_rails_...          (organization_id => organizations.id)
#  fk_rails_...          (profile_image_id => student_images.id)
#  students_group_id_fk  (group_id => groups.id)
#
FactoryBot.define do
  factory :student do
    sequence(:old_mlid, (0..99).to_a.cycle) { |n| "#{Faker::Lorem.characters(number: 1).upcase}#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    dob { Faker::Time.between from: 20.years.ago.to_datetime, to: 10.years.ago.to_datetime }
    estimated_dob { Faker::Boolean.boolean true_ratio: 0.2 }
    gender { %w[male female nonbinary].sample }
    group { create :group }
    tags { create_list :tag, 3 }
    organization { group.chapter.organization }
    mlid { MindleapsIdService.generate_student_mlid organization.id }
    transient do
      grades { {} }
      subject { nil }
    end

    factory :graded_student do
      after :create do |student, evaluator|
        unless evaluator.grades.empty?
          subject = evaluator.subject || create(
            :subject_with_skills,
            skill_names: evaluator.grades.keys,
            organization: student.group.chapter.organization
          )
          (0..(evaluator.grades.values.map(&:length).max - 1)).each do |i|
            date = 1.year.ago.to_date + i.days
            existing_lesson = Lesson.find_by(subject_id: subject.id, group_id: student.group.id, date:)
            skill_marks = evaluator.grades.transform_values { |v| v[i] }
            if existing_lesson
              skill_marks.each do |skill_name, mark|
                skill = Skill.joins(:subjects).find_by skill_name:, 'subjects.id': subject.id
                gd = GradeDescriptor.find_by(skill:, mark:)
                create :grade, student_id: student.id, grade_descriptor: gd, lesson: existing_lesson
              end
            else
              create(
                :lesson_with_grades,
                subject:,
                group: student.group,
                date:,
                student_grades: { student.id => skill_marks }
              )
            end
          end
        end
      end
    end
  end
end
