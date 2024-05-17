class RemoveUnusedLessonReferences < ActiveRecord::Migration[7.0]
  def change
    remove_column :lessons, :old_id, :integer
    remove_column :grades, :lesson_uid, :uuid
    remove_column :grades, :old_lesson_id, :integer
    remove_column :absences, :old_lesson_id, :integer
  end
end
