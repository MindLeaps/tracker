class AddActiveGradeStatisticsIndex < ActiveRecord::Migration[7.2]
  disable_ddl_transaction!

  INDEX_NAME = :index_active_grades_on_lesson_and_student_for_statistics

  def up
    add_index :grades,
              [:lesson_id, :student_id],
              include: [:mark, :skill_id],
              where: 'deleted_at IS NULL',
              algorithm: :concurrently,
              name: INDEX_NAME
  end

  def down
    remove_index :grades, name: INDEX_NAME, algorithm: :concurrently
  end
end
