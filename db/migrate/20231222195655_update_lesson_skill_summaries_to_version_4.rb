class UpdateLessonSkillSummariesToVersion4 < ActiveRecord::Migration[7.0]
  def change
    update_view :lesson_skill_summaries, version: 4, revert_to_version: 3
  end
end
