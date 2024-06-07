class UpdateLessonIds < ActiveRecord::Migration[7.0]
  def up
    # rubocop:disable Rails/DangerousColumnNames
    drop_views
    drop_foreign_keys
    remove_foreign_key :grades, :lessons
    rename_column(:lessons, :id, :old_id)
    rename_column(:lessons, :uid, :id)
    switch_lessons_primary_key

    remove_index :grades, :lesson_id
    rename_column(:grades, :lesson_id, :lesson_old_id)
    rename_column(:grades, :lesson_uid, :lesson_id)
    # index on lesson_uid already existed so when that column is renamed the index is preserved

    remove_index :absences, :lesson_id
    rename_column(:absences, :lesson_id, :lesson_old_id)
    add_column(:absences, :lesson_id, :uuid)
    switch_absences_lesson_ids
    change_column(:absences, :lesson_id, :uuid, null: false)
    add_index :absences, :lesson_id

    reintroduce_foreign_keys
    new_views
    # rubocop:enable Rails/DangerousColumnNames
  end

  def down
    # rubocop:disable Rails/DangerousColumnNames
    drop_views
    drop_foreign_keys
    rename_column(:lessons, :id, :uid)
    rename_column(:lessons, :old_id, :id)
    switch_lessons_primary_key

    # we preserve the index on lesson_id so when the column gets renamed to lesson_uid index is preserved
    rename_column(:grades, :lesson_id, :lesson_uid)
    rename_column(:grades, :lesson_old_id, :lesson_id)
    add_index :grades, :lesson_id

    remove_index :absences, :lesson_id
    remove_column(:absences, :lesson_id)
    rename_column(:absences, :lesson_old_id, :lesson_id)
    add_index :absences, :lesson_id

    reintroduce_foreign_keys
    add_foreign_key :grades, :lessons, column: :lesson_uid, primary_key: :uid, name: 'grades_lesson_uid_fk'
    old_views
    # rubocop:enable Rails/DangerousColumnNames
  end

  def drop_foreign_keys
    remove_foreign_key :grades, :lessons
    remove_foreign_key :absences, :lessons
  end

  def switch_lessons_primary_key
    # cascade ensures to drop FKs depending on this PK
    execute <<~SQL
      alter table lessons drop constraint lessons_pkey;
      alter table lessons add primary key(id);
    SQL
  end

  def switch_absences_lesson_ids
    execute <<~SQL
      update absences a set lesson_id = l.id
        from lessons l where l.old_id = a.lesson_old_id;
    SQL
  end

  def reintroduce_foreign_keys
    add_foreign_key :grades, :lessons, column: :lesson_id, name: 'grades_lesson_id_fk'
    add_foreign_key :absences, :lessons, column: :lesson_id, name: 'absences_lesson_id_fk'
  end

  def drop_views
    drop_view :student_lessons
    drop_view :group_lesson_summaries
    drop_view :lesson_table_rows
    drop_view :performance_per_group_per_skill_per_lessons
    drop_view :student_lesson_details
    drop_view :student_lesson_summaries
    drop_view :lesson_skill_summaries
  end

  def old_views
    create_view :student_lessons, version: 1
    create_view :group_lesson_summaries, version: 2
    create_view :lesson_table_rows, version: 2
    create_view :performance_per_group_per_skill_per_lessons, version: 1
    create_view :student_lesson_details, version: 2
    create_view :student_lesson_summaries, version: 5
    create_view :lesson_skill_summaries, version: 5
  end

  def new_views
    create_view :student_lessons, version: 1
    create_view :group_lesson_summaries, version: 3
    create_view :lesson_table_rows, version: 2
    create_view :performance_per_group_per_skill_per_lessons, version: 1
    create_view :student_lesson_details, version: 2
    create_view :student_lesson_summaries, version: 5
    create_view :lesson_skill_summaries, version: 6
  end
end
