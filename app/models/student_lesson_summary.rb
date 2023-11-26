# frozen_string_literal: true

# == Schema Information
#
# Table name: student_lesson_summaries
#
#  absent       :boolean
#  average_mark :decimal(, )
#  deleted_at   :datetime
#  first_name   :string
#  grade_count  :bigint
#  last_name    :string
#  skill_count  :bigint
#  group_id     :integer
#  lesson_id    :integer
#  student_id   :integer
#  subject_id   :integer
#
class StudentLessonSummary < ApplicationRecord
  # Alias for table_order scope of Application record. This is needed because has_scope does not allow for 2 scopes with the same name
  singleton_class.send(:alias_method, :table_order_lesson_students, :table_order)

  def readonly?
    true
  end
end
