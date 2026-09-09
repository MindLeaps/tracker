class CreateOrganizationLessonSummaries < ActiveRecord::Migration[7.2]
  def change
    create_view :organization_lesson_summaries, version: 1
  end
end
