class UpdateStudentLessonSummariesToVersion4 < ActiveRecord::Migration[5.2]
  def change
    update_view :student_lesson_summaries, version: 4, revert_to_version: 3
  end
end
