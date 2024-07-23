class RemoveOldLessonId < ActiveRecord::Migration[7.1]
  def change
    # rubocop:disable Rails/ReversibleMigration
    drop_view :lesson_table_rows
    remove_column :grades, :lesson_old_id
    remove_column :lessons, :old_id
    create_view :lesson_table_rows, version: 3
    # rubocop:enable Rails/ReversibleMigration
  end
end
