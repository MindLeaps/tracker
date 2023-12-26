# frozen_string_literal: true

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
  def readonly?
    true
  end
end
