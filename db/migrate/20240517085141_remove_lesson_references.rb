class RemoveLessonReferences < ActiveRecord::Migration[7.0]
  def change
    drop_view :student_lessons, revert_to_version: 1
    drop_view :group_lesson_summaries, revert_to_version: 2
    drop_view :lesson_table_rows, revert_to_version: 2
    drop_view :performance_per_group_per_skill_per_lessons, revert_to_version: 1
    drop_view :student_lesson_details, revert_to_version: 2
    drop_view :student_lesson_summaries, revert_to_version: 5
    drop_view :lesson_skill_summaries, revert_to_version: 5

    remove_foreign_key :grades, :lessons
    remove_foreign_key :grades, :lessons, name: :grades_lesson_uid_fk
    remove_foreign_key :absences, :lessons

    remove_index :grades, :lesson_uid
  end
end
