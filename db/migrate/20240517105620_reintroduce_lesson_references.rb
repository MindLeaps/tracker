class ReintroduceLessonReferences < ActiveRecord::Migration[7.0]
  def change
    create_view :student_lessons, version: 1
    create_view :group_lesson_summaries, version: 3
    create_view :lesson_table_rows, version: 2
    create_view :performance_per_group_per_skill_per_lessons, version: 1
    create_view :student_lesson_details, version: 2
    create_view :student_lesson_summaries, version: 5
    create_view :lesson_skill_summaries, version: 6

    add_foreign_key :grades, :lessons, name: 'grades_lesson_id_fk'
    add_foreign_key :absences, :lessons

    add_index :grades, :lesson_id
    add_index :absences, :lesson_id
  end
end
