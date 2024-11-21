class UpdateEnrollmentsAccordingToGrades < ActiveRecord::Migration[7.2]
  def up
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
          join enrollments en on en.student_id = s.id and en.group_id = s.group_id and en.active_since::date > l.date
          where l.date > now() - '3 years'::interval
          group by s.id, s.group_id, en.id
        )

        -- Update found enrollments
        update enrollments en set active_since = tfe.earliest_lesson::timestamp
        from tofix_enrollments tfe
        where en.id = tfe.enrollment_id;
      END;
      $$;
    SQL
  end

  def down
    execute <<~SQL
      DROP PROCEDURE IF EXISTS update_enrollments_by_grades;
    SQL
  end
end
