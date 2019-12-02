# frozen_string_literal: true

class UpdateLessonTableRowsToVersion2 < ActiveRecord::Migration[5.2]
  def change
    update_view :lesson_table_rows, version: 2, revert_to_version: 1
  end
end
