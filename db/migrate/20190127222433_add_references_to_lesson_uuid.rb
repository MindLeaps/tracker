# frozen_string_literal: true

class AddReferencesToLessonUuid < ActiveRecord::Migration[5.2]
  def up
    add_column :grades, :lesson_uid, :uuid
    add_index :grades, :lesson_uid
    add_foreign_key :grades, :lessons, column: :lesson_uid, primary_key: :uid, name: 'grades_lesson_uid_fk'

    execute <<~SQL.squish
      UPDATE grades SET lesson_uid = l.uid FROM lessons l WHERE lesson_id = l.id;
    SQL

    change_column_null :grades, :lesson_uid, false
  end

  def down
    remove_index :grades, column: :lesson_uid
    remove_column :grades, :lesson_uid
  end
end
