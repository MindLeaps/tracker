class RemoveFutureLessonsAndGrades < ActiveRecord::Migration[7.2]
  def up
    today = Time.zone.today

    transaction do
      lessons_to_delete = Lesson.where('date > ?', today)
      grades_to_delete = Grade.where(lesson_id: lessons_to_delete.select(:id))

      grades_to_delete.delete_all
      lessons_to_delete.delete_all
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot safely restore future lessons and grades'
  end
end
