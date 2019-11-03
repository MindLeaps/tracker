# frozen_string_literal: true

class UpdateStudentLessonSummariesToVersion3 < ActiveRecord::Migration[5.2]
  def change
    update_view :student_lesson_summaries, version: 3, revert_to_version: 2
  end
end
