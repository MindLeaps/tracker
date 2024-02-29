class CreateStudentLessons < ActiveRecord::Migration[5.2]
  def change
    create_view :student_lessons
  end
end
