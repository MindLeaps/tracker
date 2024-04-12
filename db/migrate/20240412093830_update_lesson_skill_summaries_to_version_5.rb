class UpdateLessonSkillSummariesToVersion5 < ActiveRecord::Migration[7.0]
  def change
    replace_view :lesson_skill_summaries, version: 5, revert_to_version: 4
  end
end
