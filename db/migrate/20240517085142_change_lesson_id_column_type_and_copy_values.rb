class ChangeLessonIdColumnTypeAndCopyValues < ActiveRecord::Migration[7.0]
  def up
    # rubocop:disable Rails/SkipsModelValidations
    # rubocop:disable Rails/DangerousColumnNames
    add_column(:lessons, :old_id, :integer)
    add_column(:grades, :old_lesson_id, :integer)
    add_column(:absences, :old_lesson_id, :integer)

    Lesson.update_all('old_id = id')
    Grade.update_all('old_lesson_id = lesson_id')
    Absence.update_all('old_lesson_id = lesson_id')

    remove_column(:lessons, :id)
    rename_column(:lessons, :uid, :id)
    execute 'ALTER TABLE lessons ADD PRIMARY KEY (id);'
    remove_column(:grades, :lesson_id)
    remove_column(:absences, :lesson_id)

    add_column(:grades, :lesson_id, :uuid, null: false, default: 'uuid_generate_v4()')
    add_column(:absences, :lesson_id, :uuid, null: false, default: 'uuid_generate_v4()')

    Lesson.pluck(:id, :old_id).each do
      Grade.where(old_lesson_id: :old_id).update_all(lesson_id: :id)
      Absence.where(old_lesson_id: :old_id).update_all(lesson_id: :id)
    end
    # rubocop:enable Rails/DangerousColumnNames
    # rubocop:enable Rails/SkipsModelValidations
  end

  def down
    # rubocop:disable Rails/SkipsModelValidations
    # rubocop:disable Rails/DangerousColumnNames
    remove_column(:grades, :lesson_id, type: :uuid)
    remove_column(:absences, :lesson_id, :uuid)
    rename_column(:lessons, :id, :uid)

    add_column(:lessons, :id, :integer)
    add_column(:grades, :lesson_id, :integer)
    add_column(:absences, :lesson_id, :integer)

    Lesson.update_all('id = old_id')
    Grade.update_all('lesson_id = old_lesson_id')
    Absence.update_all('lesson_id = old_lesson_id')

    remove_column(:lessons, :old_id)
    remove_column(:grades, :old_lesson_id)
    remove_column(:absences, :old_lesson_id)
    # rubocop:enable Rails/DangerousColumnNames
    # rubocop:enable Rails/SkipsModelValidations
  end
end
