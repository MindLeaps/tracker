# frozen_string_literal: true

class CreateGroupLessonSummaries < ActiveRecord::Migration[5.2]
  def change
    create_view :group_lesson_summaries
  end
end
