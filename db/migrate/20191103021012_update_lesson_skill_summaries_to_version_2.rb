class UpdateLessonSkillSummariesToVersion2 < ActiveRecord::Migration[5.2]
  def change
    update_view :lesson_skill_summaries, version: 2, revert_to_version: 1
  end
end
