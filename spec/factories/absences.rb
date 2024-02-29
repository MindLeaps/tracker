# == Schema Information
#
# Table name: absences
#
#  id         :integer          not null, primary key
#  lesson_id  :integer          not null
#  student_id :integer          not null
#
# Indexes
#
#  index_absences_on_lesson_id   (lesson_id)
#  index_absences_on_student_id  (student_id)
#
# Foreign Keys
#
#  fk_rails_...  (lesson_id => lessons.id)
#  fk_rails_...  (student_id => students.id)
#
FactoryBot.define do
  factory :absence do
    student { create :student }
    lesson { create :lesson }
  end
end
