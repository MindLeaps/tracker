class UpdateEnrollmentColumns < ActiveRecord::Migration[7.2]
  def up
    drop_relative_views
    change_column :enrollments, :active_since, :date, null: false
    change_column :enrollments, :inactive_since, :date
    update_enrollments_by_grades_procedure

    execute <<~SQL
      CALL update_enrollments_by_grades();
    SQL

    create_relative_views
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'This migration cannot be reverted because it modified data.'
  end

  def drop_relative_views
    drop_view :group_lesson_summaries
    drop_view :lesson_table_rows
    drop_view :student_lesson_details
    drop_view :student_lesson_summaries
  end

  def create_relative_views
    create_view :student_lesson_summaries, version: 8
    create_view :student_lesson_details, version: 5
    create_view :lesson_table_rows, version: 4
    create_view :group_lesson_summaries, version: 5
  end

  def update_enrollments_by_grades_procedure
    execute <<~SQL
      CREATE OR REPLACE PROCEDURE update_enrollments_by_grades()
      LANGUAGE plpgsql
      AS $$
      BEGIN
        -- Find enrollments to fix (ignore grades that reference lessons from more than 3 years ago)
        with tofix_enrollments as
        ( select s.id as student_id, s.group_id, min(l.date) as earliest_lesson, min(en.active_since) as enrollment_date, en.id as enrollment_id
          from grades as gr
          join students s on s.id = gr.student_id
          join lessons l on gr.lesson_id = l.id
          join enrollments en on en.student_id = s.id and en.group_id = s.group_id and en.active_since > l.date
          where l.date > now() - '3 years'::interval
          group by s.id, s.group_id, en.id
        )

        -- Update found enrollments
        update enrollments en set active_since = tfe.earliest_lesson
        from tofix_enrollments tfe
        where en.id = tfe.enrollment_id;
      END;
      $$;
    SQL
  end
end
