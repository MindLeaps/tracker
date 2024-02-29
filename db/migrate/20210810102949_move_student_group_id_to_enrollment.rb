class MoveStudentGroupIdToEnrollment < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      insert into enrollments (student_id, group_id, active_since, inactive_since, created_at, updated_at)
      select id as student_id, group_id as group_id, created_at as active_since, null as inactive_since, NOW() as created_at, now() as updated_at from students;
    SQL
  end

  def down
    execute <<~SQL
      DELETE FROM enrollments;
    SQL
  end
end
