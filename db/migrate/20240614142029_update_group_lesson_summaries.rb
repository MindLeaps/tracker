class UpdateGroupLessonSummaries < ActiveRecord::Migration[7.1]
  def change
    update_view :group_lesson_summaries, version: 4, revert_to_version: 3
  end
end
