class UpdateEnrollmentsAccordingToGrades < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      CREATE OR REPLACE PROCEDURE update_enrollments_by_grades()
      LANGUAGE plpgsql
      AS $$
      BEGIN
        -- Find enrollments to fix
        with tofix_enrollments as
        ( select s.id as student_id, s.group_id, min(l.date) as earliest_lesson, min(en.active_since) as enrollment_date, en.id as enrollment_id
        from grades as g
        join students s on s.id = g.student_id
        join lessons l on g.lesson_id = l.id
        join groups gr on gr.id = l.group_id
        join enrollments en on en.student_id = s.id and en.group_id = gr.id and en.active_since > l.date
        where l.date > now() - '3 years'::interval
        group by s.id, s.group_id, en.id
        )

        -- Update found enrollments
        update enrollments en set active_since = tfe.earliest_lesson::timestamp
        from tofix_enrollments tfe
        where en.id = tfe.enrollment_id;
      END;
      $$;
      CALL update_enrollments_by_grades();
    SQL
  end

  def down
    execute <<~SQL
      DROP PROCEDURE IF EXISTS update_enrollments_by_grades;
    SQL
  end
end
