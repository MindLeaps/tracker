class RemoveGradeUniquenessConstraint < ActiveRecord::Migration[5.0]
  def change
    remove_index :grades, column: %i[student_id lesson_id grade_descriptor_id]
  end
end
