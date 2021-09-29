# frozen_string_literal: true

class CreatePerformancePerGroupPerSkillPerLessons < ActiveRecord::Migration[6.1]
  def change
    create_view :performance_per_group_per_skill_per_lessons
  end
end
