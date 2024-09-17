class AddAttendanceToGroupLessonSummaries < ActiveRecord::Migration[7.1]
  def change
    update_view :group_lesson_summaries, version: 5, revert_to_version: 4
  end
end
