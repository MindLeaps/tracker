class ChangeLessonIdColumnTypeAndCopyValues < ActiveRecord::Migration[7.0]
  def up
    # rubocop:disable Rails/SkipsModelValidations
    # rubocop:disable Rails/DangerousColumnNames
    rename_column(:lessons, :id, :old_id)
    rename_column(:grades, :lesson_id, :old_lesson_id)
    add_column(:absences, :lesson_uid, :uuid)

    rename_column(:lessons, :uid, :id)
    execute 'ALTER TABLE lessons ADD PRIMARY KEY (id);'
    rename_column(:grades, :lesson_uid, :lesson_id)
    rename_column(:absences, :lesson_id, :old_lesson_id)
    rename_column(:absences, :lesson_uid, :lesson_id)

    Absence.update_all(lesson: Lesson.find(id: :old_lesson_id))
    change_column(:absences, :lesson_id, :uuid, null: false)
    # rubocop:enable Rails/DangerousColumnNames
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    # rubocop:disable Rails/SkipsModelValidations
    # rubocop:disable Rails/DangerousColumnNames
    rename_column(:grades, :lesson_id, :lesson_uid)
    rename_column(:grades, :old_lesson_id, :lesson_id)
    rename_column(:absences, :lesson_id, :lesson_uid)
    rename_column(:absences, :old_lesson_id, :lesson_id)
    rename_column(:lesson, :id, :uid)
    rename_column(:lesson, :old_id, :id)

    remove_column(:absences, :lesson_uid)
    # rubocop:enable Rails/DangerousColumnNames
    # rubocop:enable Rails/SkipsModelValidations
  end
end
