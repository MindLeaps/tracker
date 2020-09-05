# frozen_string_literal: true

class StudentLessonDetail < ApplicationRecord
  def skill_names_marks
    skill_marks.values.reduce({}) { |acc, v| acc.update(v['skill_name'] => v['mark']) }
  end

  scope :exclude_empty, -> { where.not(average_mark: nil) }
end
