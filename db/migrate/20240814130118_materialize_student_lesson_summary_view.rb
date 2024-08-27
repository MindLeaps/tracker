class MaterializeStudentLessonSummaryView < ActiveRecord::Migration[7.1]
  def up
    drop_dependent_views
    drop_view :student_lesson_summaries
    create_view :student_lesson_summaries, version: 7, materialized: true
    create_dependent_views

    execute <<~SQL.squish
      -- Create extension
      CREATE EXTENSION pg_cron;

      -- Schedule refreshing the student lesson summary view every 6 hours
      SELECT cron.schedule('student_lesson_summaries', '0 */6 * * *',
        $CRON$ REFRESH MATERIALIZED VIEW student_lesson_summaries; $CRON$
      );
    SQL
  end

  def down
    drop_dependent_views
    Scenic.database.drop_materialized_view('student_lesson_summaries')
    create_view :student_lesson_summaries, version: 7, materialized: false
    create_dependent_views

    execute <<~SQL.squish
      SELECT cron.unschedule('student_lesson_summaries');

      DROP EXTENSION IF EXISTS pg_cron;
    SQL
  end

  def create_dependent_views
    create_view :group_lesson_summaries, version: 4
    create_view :lesson_table_rows, version: 4
  end

  def drop_dependent_views
    drop_view :group_lesson_summaries
    drop_view :lesson_table_rows
  end
end
