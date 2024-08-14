class MaterializeStudentLessonSummaryView < ActiveRecord::Migration[7.1]
  def up
    drop_views
    create_view :student_lesson_summaries, version: 6, materialized: true
    create_dependent_views

    execute <<~SQL.squish
      -- Schedule refreshing the student lesson summary view every 6 hours
      SELECT cron.schedule('student_lesson_summary', '0 */6 * * *',
        $CRON$ REFRESH MATERIALIZED VIEW student_lesson_summary; $CRON$
      );
    SQL
  end

  def down
    drop_views
    create_view :student_lesson_summaries, version: 6, materialized: false
    create_dependent_views

    execute <<~SQL.squish
      SELECT cron.unschedule('student_lesson_summary');
    SQL
  end

  def create_dependent_views
    create_view :group_lesson_summaries, version: 4
    create_view :lesson_table_rows, version: 3
  end

  def drop_views
    drop_view :group_lesson_summaries
    drop_view :lesson_table_rows
    drop_view :student_lesson_summaries
  end
end
