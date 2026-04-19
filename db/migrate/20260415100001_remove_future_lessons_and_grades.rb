class RemoveFutureLessonsAndGrades < ActiveRecord::Migration[7.2]
  def up
    today = Time.zone.today

    transaction do
      lessons_to_delete = Lesson.where('date > ?', today)
      grades_to_delete = Grade.where(lesson_id: lessons_to_delete.select(:id))

      lessons_to_delete.find_each do |lesson|
        DeletedLesson.find_or_create_by!(id: lesson.id) do |deleted_lesson|
          deleted_lesson.group_id = lesson.group_id
        end
      end

      grades_to_delete.delete_all
      lessons_to_delete.delete_all
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Cannot safely restore future lessons and grades'
  end
end
