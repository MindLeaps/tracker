class UpdateStudentTableRowsToVersion4 < ActiveRecord::Migration[7.2]
  def change
    update_view :student_table_rows, version: 4, revert_to_version: 3
  end
end
