class UpdateViewsUsingOldStudentGroupId < ActiveRecord::Migration[7.2]
  def change
    update_view :student_lesson_details, version: 6, revert_to_version: 5
  end
end
