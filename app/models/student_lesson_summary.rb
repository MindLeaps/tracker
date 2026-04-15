# == Schema Information
#
# Table name: student_lesson_summaries
#
#  average_mark :decimal(, )
#  deleted_at   :datetime
#  first_name   :string
#  grade_count  :bigint
#  last_name    :string
#  lesson_date  :date
#  skill_count  :bigint
#  group_id     :integer
#  lesson_id    :uuid
#  student_id   :integer
#  subject_id   :integer
#
class StudentLessonSummary < ApplicationRecord
  alias_table_order_scope :table_order_lesson_students

  def readonly?
    true
  end
end
