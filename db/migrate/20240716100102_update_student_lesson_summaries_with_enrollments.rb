class UpdateStudentLessonSummariesWithEnrollments < ActiveRecord::Migration[7.1]
  def up
    drop_view :group_lesson_summaries
    drop_view :lesson_table_rows

    update_view :student_lesson_summaries, version: 7

    create_view :group_lesson_summaries, version: 4
    create_view :lesson_table_rows, version: 4
    update_trigger
  end

  def down
    drop_view :group_lesson_summaries
    drop_view :lesson_table_rows

    update_view :student_lesson_summaries, version: 6

    create_view :group_lesson_summaries, version: 4
    create_view :lesson_table_rows, version: 3
    old_trigger
  end

  def update_trigger
    execute <<~SQL
      create or replace function update_enrollments()
      returns trigger AS
      $BODY$
      declare
        current_enrollment_group_id int := null;
      BEGIN
        -- Find the current group the student is enrolled in
        SELECT group_id into current_enrollment_group_id FROM enrollments e where e.student_id = new.id and e.inactive_since is null;
        -- Insert a new enrollment if this is the first time the student is being enrolled
        if current_enrollment_group_id is null then
            insert into enrollments (student_id, group_id, active_since, inactive_since, created_at, updated_at)
            values (new.id, new.group_id, now(), null, now(), now());
        else if current_enrollment_group_id != new.group_id then
            -- Insert a new enrollment  if this is a different group the student is being enrolled in
            insert into enrollments (student_id, group_id, active_since, inactive_since, created_at, updated_at)
            values (new.id, new.group_id, now(), null, now(), now());
            -- Update the previous enrollment for the student and make it inactive
            update enrollments set inactive_since = now(), updated_at = now()
            where inactive_since is null and group_id = current_enrollment_group_id and student_id = new.id;
        end if;
        end if;
        return new;
      END;
      $BODY$ language plpgsql;

      drop trigger if exists update_enrollments_on_student_group_change_trigger on students;
      create trigger update_enrollments_on_student_group_change_trigger
      after insert or update on students for each row execute procedure update_enrollments();
    SQL
  end

  def old_trigger
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

      drop trigger if exists update_enrollments_on_student_group_change_trigger on students;
      create trigger update_enrollments_on_student_group_change_trigger
      after insert or update on students for each row execute procedure update_enrollments();
    SQL
  end
end
