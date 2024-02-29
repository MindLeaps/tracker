class CreateStudentLessonDetails < ActiveRecord::Migration[5.2]
  def change
    create_view :student_lesson_details
  end
end
