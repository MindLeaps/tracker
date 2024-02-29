class UpdateStudentLessonSummariesToVersion2 < ActiveRecord::Migration[5.2]
  def change
    update_view :student_lesson_summaries, version: 2, revert_to_version: 1
  end
end
