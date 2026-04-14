class UpdateLessonTableRowsToVersion5 < ActiveRecord::Migration[7.2]
  def change
    add_index :enrollments,
              [:group_id, :active_since, :inactive_since, :student_id],
              name: :index_enrollments_on_group_dates_and_student

    update_view :lesson_table_rows, version: 5, revert_to_version: 4
  end
end
