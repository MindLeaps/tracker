# frozen_string_literal: true

class RemoveDuplicateDeletedGrades < ActiveRecord::Migration[5.2]
  def up
    execute <<~SQL
      with all_grades AS (
        select g.id as existing_id, * from grades g join grade_descriptors gd on g.grade_descriptor_id = gd.id
      ), deleted AS (
        select g.id as deleted_id, * from grades g join grade_descriptors gd on g.grade_descriptor_id = gd.id WHERE g.deleted_at IS NOT NULL
      ), deleted_ids AS (
        SELECT deleted_id from all_grades as one join (select * from deleted) as two
           on one.lesson_id = two.lesson_id AND one.skill_id = two.skill_id and one.student_id = two.student_id AND existing_id != deleted_id
      )
      DELETE FROM grades g USING deleted_ids WHERE g.id = deleted_id;
    SQL
  end

  def down
  end
end
