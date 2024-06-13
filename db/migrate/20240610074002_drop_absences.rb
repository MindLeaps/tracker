class DropAbsences < ActiveRecord::Migration[7.1]
  def up
    drop_view :student_lesson_details
    drop_table :absences

    create_view :student_lesson_details, version: 3
  end

  def down
    drop_view :student_lesson_details

    # rubocop:disable Rails/CreateTableWithTimestamps
    create_table :absences do |t|
      t.references :student, foreign_key: true, null: false
      t.references :lesson, type: :uuid, foreign_key: true, null: false
    end
    # rubocop:enable Rails/CreateTableWithTimestamps

    create_view :student_lesson_details, version: 2
  end
end
