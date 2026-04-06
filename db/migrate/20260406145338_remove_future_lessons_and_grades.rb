class RemoveFutureLessonsAndGrades < ActiveRecord::Migration[7.2]
  # rubocop:disable Rails/SkipsModelValidations
  def up
    deleted_at = Time.zone.now
    today = Time.zone.today

    transaction do
      lessons_to_delete = Lesson.where(deleted_at: nil).where('date > ?', today)
      grades_to_delete = Grade.where(deleted_at: nil, lesson_id: lessons_to_delete.select(:id))

      grades_to_delete.update_all(deleted_at: deleted_at)
      lessons_to_delete.update_all(deleted_at: deleted_at)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot safely restore future lessons and grades'
  end
end
