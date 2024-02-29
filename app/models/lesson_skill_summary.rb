# == Schema Information
#
# Table name: lesson_skill_summaries
#
#  average_mark :decimal(, )
#  grade_count  :bigint
#  lesson_uid   :uuid
#  skill_name   :string
#  skill_id     :integer
#  subject_id   :integer
#
class LessonSkillSummary < ApplicationRecord
  singleton_class.send(:alias_method, :table_order_lesson_skills, :table_order)
  def readonly?
    true
  end
end
