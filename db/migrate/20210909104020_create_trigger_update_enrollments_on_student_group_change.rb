class CreateTriggerUpdateEnrollmentsOnStudentGroupChange < ActiveRecord::Migration[6.1]
  def up
    execute <<~SQL
      create or replace function update_enrollments()
      returns trigger AS
      $BODY$
      declare
        current_enrollment_group_id int := null;
      BEGIN
        SELECT group_id into current_enrollment_group_id FROM enrollments e where e.student_id = new.id;
        if current_enrollment_group_id is null or current_enrollment_group_id != new.group_id then
          update enrollments set inactive_since = now() where inactive_since is null;
          insert into enrollments (student_id, group_id, active_since, inactive_since, created_at, updated_at)
          values (new.id, new.group_id, now(), null, now(), now());
        end if;
        return new;
      END;
      $BODY$ language plpgsql;

      create trigger update_enrollments_on_student_group_change_trigger
      after insert or update on students for each row execute procedure update_enrollments();
    SQL
  end

  def down
    execute <<~SQL
      drop trigger update_enrollments_on_student_group_change_trigger on students;
      drop function update_enrollments;
    SQL
  end
end
