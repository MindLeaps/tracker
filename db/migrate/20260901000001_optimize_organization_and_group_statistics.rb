class OptimizeOrganizationAndGroupStatistics < ActiveRecord::Migration[7.2]
  def change
    update_view :organization_summaries, version: 6, revert_to_version: 5
    update_view :group_lesson_summaries, version: 6, revert_to_version: 5
    create_view :group_skill_growths, version: 1
  end
end
