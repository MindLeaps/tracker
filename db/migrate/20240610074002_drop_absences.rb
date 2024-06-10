class DropAbsences < ActiveRecord::Migration[7.1]
  def up
    drop_view :student_lesson_details
    drop_table :absences
    create_view :student_lesson_details, version: 3
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
