# frozen_string_literal: true

class UpdateStudentTableRowsToVersion2 < ActiveRecord::Migration[6.1]
  def change
    update_view :student_table_rows, version: 2, revert_to_version: 1
  end
end
