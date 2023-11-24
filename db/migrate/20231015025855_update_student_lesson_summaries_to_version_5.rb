class UpdateStudentLessonSummariesToVersion5 < ActiveRecord::Migration[7.0]
  def change
  
    update_view :student_lesson_summaries, version: 5, revert_to_version: 4
  end
end
