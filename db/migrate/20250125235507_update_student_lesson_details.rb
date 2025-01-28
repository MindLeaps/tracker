class UpdateStudentLessonDetails < ActiveRecord::Migration[7.2]
  def change
    update_view :student_lesson_details, version: 4, revert_to_version: 3
  end
end
