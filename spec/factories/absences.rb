# == Schema Information
#
# Table name: absences
#
#  id            :integer          not null, primary key
#  lesson_id     :uuid             not null
#  lesson_old_id :integer          not null
#  student_id    :integer          not null
#
# Indexes
#
#  index_absences_on_lesson_id   (lesson_id)
#  index_absences_on_student_id  (student_id)
#
# Foreign Keys
#
#  absences_lesson_id_fk  (lesson_id => lessons.id)
#  fk_rails_...           (student_id => students.id)
#
FactoryBot.define do
  factory :absence do
    lesson_old_id { lesson.old_id }
  end
end
