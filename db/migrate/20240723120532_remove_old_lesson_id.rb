class RemoveOldLessonId < ActiveRecord::Migration[7.1]
  def up
    drop_view :lesson_table_rows
    remove_column :grades, :lesson_old_id
    remove_column :lessons, :old_id
    create_view :lesson_table_rows, version: 3
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'This migration cannot be reverted because it destroys data.'
  end
end
