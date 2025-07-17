class RemoveEnrollmentTriggerOnStudentGroupChange < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      drop trigger if exists update_enrollments_on_student_group_change_trigger on students;
    SQL
  end

  def down
    execute <<-SQL
      create trigger update_enrollments_on_student_group_change_trigger
      after insert or update on students for each row execute procedure update_enrollments();
    SQL
  end
end
