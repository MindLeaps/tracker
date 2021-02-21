# frozen_string_literal: true

class UpdateStudentTableRowsToVersion3 < ActiveRecord::Migration[6.1]
  def change
    update_view :student_table_rows, version: 3, revert_to_version: 2
  end
end
