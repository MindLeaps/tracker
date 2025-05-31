class RemoveGroupFromStudents < ActiveRecord::Migration[7.2]
  def up
    rename_column :students, :group_id, :old_group_id
    execute <<-SQL
      drop trigger if exists update_enrollments_on_student_group_change_trigger on students;
    SQL
  end

  def down
    rename_column :students, :old_group_id, :group_id
    execute <<-SQL
      create trigger update_enrollments_on_student_group_change_trigger
      after insert or update on students for each row execute procedure update_enrollments();
    SQL
  end
end
