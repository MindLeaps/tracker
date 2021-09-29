# frozen_string_literal: true

# == Schema Information
#
# Table name: student_lesson_details
#
#  absent             :boolean
#  average_mark       :decimal(, )
#  date               :date
#  first_name         :string
#  grade_count        :bigint
#  last_name          :string
#  lesson_deleted_at  :datetime
#  skill_marks        :jsonb
#  student_deleted_at :datetime
#  lesson_id          :integer
#  student_id         :integer
#  subject_id         :integer
#
class StudentLessonDetail < ApplicationRecord
  def skill_names_marks
    skill_marks.values.reduce({}) { |acc, v| acc.update(v['skill_name'] => v['mark']) }
  end

  scope :exclude_empty, -> { where.not(average_mark: nil) }
end
