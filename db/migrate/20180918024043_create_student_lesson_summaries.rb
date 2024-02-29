class CreateStudentLessonSummaries < ActiveRecord::Migration[5.2]
  def change
    create_view :student_lesson_summaries
  end
end
