class UpdateGroupLessonSummariesAndRows < ActiveRecord::Migration[7.1]
  def change
    update_view :group_lesson_summaries, version: 4, revert_to_version: 3
    update_view :lesson_table_rows, version: 3, revert_to_version: 2
  end
end
