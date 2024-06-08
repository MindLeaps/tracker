# == Schema Information
#
# Table name: lesson_table_rows
#
#  id                   :uuid
#  average_mark         :decimal(, )
#  chapter_name         :string
#  date                 :date
#  deleted_at           :datetime
#  graded_student_count :bigint
#  group_name           :string
#  group_student_count  :bigint
#  subject_name         :string
#  created_at           :datetime
#  updated_at           :datetime
#  group_id             :integer
#  old_id               :integer
#  subject_id           :integer
#
class LessonTableRow < ApplicationRecord
  belongs_to :group
  def readonly?
    true
  end
end
