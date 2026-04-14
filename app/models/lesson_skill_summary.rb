# == Schema Information
#
# Table name: lesson_skill_summaries
#
#  average_mark :decimal(, )
#  grade_count  :bigint
#  skill_name   :string
#  lesson_id    :uuid
#  skill_id     :integer
#  subject_id   :integer
#
class LessonSkillSummary < ApplicationRecord
  alias_table_order_scope :table_order_lesson_skills
  def readonly?
    true
  end
end
