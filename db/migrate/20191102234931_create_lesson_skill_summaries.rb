# frozen_string_literal: true

class CreateLessonSkillSummaries < ActiveRecord::Migration[5.2]
  def change
    create_view :lesson_skill_summaries
  end
end
