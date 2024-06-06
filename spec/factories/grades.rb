# == Schema Information
#
# Table name: grades
#
#  id                  :integer          not null, primary key
#  deleted_at          :datetime
#  mark                :integer          not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  grade_descriptor_id :integer          not null
#  lesson_id           :uuid             not null
#  old_lesson_id       :integer          not null
#  skill_id            :bigint           not null
#  student_id          :integer          not null
#
# Indexes
#
#  index_grades_on_grade_descriptor_id  (grade_descriptor_id)
#  index_grades_on_lesson_id            (lesson_id)
#  index_grades_on_skill_id             (skill_id)
#  index_grades_on_student_id           (student_id)
#
# Foreign Keys
#
#  fk_rails_...                   (skill_id => skills.id)
#  grades_grade_descriptor_id_fk  (grade_descriptor_id => grade_descriptors.id)
#  grades_lesson_id_fk            (lesson_id => lessons.id)
#  grades_student_id_fk           (student_id => students.id)
#
FactoryBot.define do
  factory :grade do
    lesson { create :lesson }
    student { create :student }
    grade_descriptor { create :grade_descriptor }
  end
end
